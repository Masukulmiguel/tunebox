const http = require('http');
const https = require('https');
const url = require('url');

const PORT = process.env.PORT || 9090;

const searchCache = new Map();
const streamCache = new Map();

const YOUTUBE_SEARCH_HTML = 'https://www.youtube.com/results';
const USER_AGENTS = [
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
];

function setCors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');
}

function jsonResponse(res, status, data) {
  setCors(res);
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

function fetchPage(urlStr) {
  return new Promise((resolve, reject) => {
    const ua = USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
    const options = url.parse(urlStr);
    options.headers = {
      'User-Agent': ua,
      'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      'Accept': 'text/html,application/xhtml+xml',
    };
    const protocol = options.protocol === 'https:' ? https : http;
    const req = protocol.get(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve(data));
    });
    req.on('error', reject);
    req.setTimeout(15000, () => { req.destroy(); reject(new Error('timeout')); });
  });
}

async function youtubeSearch(query, limit) {
  const searchUrl = `${YOUTUBE_SEARCH_HTML}?search_query=${encodeURIComponent(query)}&sp=EgIQAQ%3D%3D`;
  const html = await fetchPage(searchUrl);
  const match = html.match(/var ytInitialData = ({.*?});\s*<\/script>/s) || html.match(/var ytInitialData = ({.*?});/);
  if (!match) return [];
  const ytData = JSON.parse(match[1]);
  const contents = ytData?.contents?.twoColumnSearchResultsRenderer
    ?.primaryContents?.sectionListRenderer?.contents?.[0]
    ?.itemSectionRenderer?.contents || [];
  const songs = [];
  for (const item of contents) {
    const vid = item.videoRenderer;
    if (!vid) continue;
    const id = vid.videoId;
    const title = vid.title?.runs?.[0]?.text || '';
    const artist = vid.ownerText?.runs?.[0]?.text || 'Unknown';
    const duration = vid.lengthText?.simpleText || '0:00';
    const thumbs = vid.thumbnail?.thumbnails || [];
    const thumb = thumbs.length > 0 ? thumbs[thumbs.length - 1].url : '';
    const durationParts = duration.split(':').map(Number);
    let durationSec = 0;
    if (durationParts.length === 3) durationSec = durationParts[0]*3600 + durationParts[1]*60 + durationParts[2];
    else if (durationParts.length === 2) durationSec = durationParts[0]*60 + durationParts[1];
    else durationSec = durationParts[0] || 0;
    songs.push({ id, title, artist, album: query, duration: durationSec, cover_url: thumb, web_url: `https://www.youtube.com/watch?v=${id}` });
    if (songs.length >= limit) break;
  }
  return songs;
}

async function getAudioStreamUrl(videoId) {
  try {
    const ytdl = require('@distube/ytdl-core');
    const info = await ytdl.getInfo(videoId);
    const format = ytdl.chooseFormat(info.formats, { quality: 'highestaudio', filter: 'audioonly' });
    return format.url;
  } catch (e) {
    return null;
  }
}

function proxyStream(ytUrl, req, res) {
  setCors(res);
  const ua = USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
  const parsedUrl = url.parse(ytUrl);
  const options = {
    hostname: parsedUrl.hostname,
    path: parsedUrl.path,
    method: 'GET',
    headers: {
      'User-Agent': ua,
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Range': req.headers.range || '',
    },
  };
  const protocol = parsedUrl.protocol === 'https:' ? https : http;
  const proxyReq = protocol.request(options, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, {
      'Content-Type': proxyRes.headers['content-type'] || 'audio/mpeg',
      'Content-Length': proxyRes.headers['content-length'] || '',
      'Content-Range': proxyRes.headers['content-range'] || '',
      'Accept-Ranges': 'bytes',
      'Access-Control-Allow-Origin': '*',
    });
    proxyRes.pipe(res);
  });
  proxyReq.on('error', () => {
    if (!res.headersSent) {
      res.writeHead(502, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'proxy error' }));
    }
  });
  proxyReq.setTimeout(30000, () => { proxyReq.destroy(); });
  proxyReq.end();
}

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const params = parsed.query;

  if (req.method === 'OPTIONS') {
    setCors(res);
    res.writeHead(204);
    res.end();
    return;
  }

  if (parsed.pathname === '/health') {
    jsonResponse(res, 200, { status: 'ok', engine: 'ytdl-core-proxy' });
    return;
  }

  if (parsed.pathname === '/search') {
    const query = params.q || '';
    const limit = parseInt(params.limit) || 20;
    if (!query) { jsonResponse(res, 400, { error: 'query required' }); return; }
    const cacheKey = `${query}:${limit}`;
    if (searchCache.has(cacheKey)) {
      jsonResponse(res, 200, searchCache.get(cacheKey));
      return;
    }
    try {
      const songs = await youtubeSearch(query, limit);
      const data = { songs, total: songs.length };
      searchCache.set(cacheKey, data);
      if (searchCache.size > 200) searchCache.delete(searchCache.keys().next().value);
      for (const s of songs.slice(0, 5)) {
        if (!streamCache.has(s.id)) {
          getAudioStreamUrl(s.id).then(url => { if (url) streamCache.set(s.id, url); }).catch(() => {});
        }
      }
      jsonResponse(res, 200, data);
    } catch (e) {
      jsonResponse(res, 500, { error: 'search failed', details: e.message });
    }
    return;
  }

  if (parsed.pathname === '/stream') {
    const videoId = params.id || '';
    if (!videoId) { jsonResponse(res, 400, { error: 'id required' }); return; }
    try {
      let streamUrl = streamCache.get(videoId);
      if (!streamUrl) {
        streamUrl = await getAudioStreamUrl(videoId);
        if (streamUrl) streamCache.set(videoId, streamUrl);
      }
      if (!streamUrl) { jsonResponse(res, 500, { error: 'could not get stream' }); return; }
      jsonResponse(res, 200, { stream_url: streamUrl });
    } catch (e) {
      jsonResponse(res, 500, { error: 'could not get stream', details: e.message });
    }
    return;
  }

  if (parsed.pathname === '/audio') {
    const videoId = params.id || '';
    if (!videoId) { res.writeHead(400); res.end('id required'); return; }
    try {
      let streamUrl = streamCache.get(videoId);
      if (!streamUrl) {
        streamUrl = await getAudioStreamUrl(videoId);
        if (streamUrl) streamCache.set(videoId, streamUrl);
      }
      if (!streamUrl) { res.writeHead(502); res.end('no stream'); return; }
      proxyStream(streamUrl, req, res);
    } catch (e) {
      res.writeHead(500); res.end('error');
    }
    return;
  }

  jsonResponse(res, 404, { error: 'not found' });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Music API running on port ${PORT}`);
});
