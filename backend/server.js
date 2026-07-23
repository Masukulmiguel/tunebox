const http = require('http');
const url = require('url');
const ytdl = require('@distube/ytdl-core');

const PORT = process.env.PORT || 9090;

const searchCache = new Map();
const streamCache = new Map();

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

function YouTubeSearch(query, limit) {
  return new Promise((resolve, reject) => {
    const searchUrl = `https://www.youtube.com/results?search_query=${encodeURIComponent(query)}&sp=EgIQAQ%3D%3D`;
    
    const options = {
      hostname: 'www.youtube.com',
      path: `/results?search_query=${encodeURIComponent(query)}&sp=EgIQAQ%3D%3D`,
      method: 'GET',
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
        'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const match = data.match(/var ytInitialData = ({.*?});/);
          if (!match) {
            resolve([]);
            return;
          }
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
            const thumb = vid.thumbnail?.thumbnails?.slice(-1)?.[0]?.url || '';

            const durationParts = duration.split(':').map(Number);
            let durationSec = 0;
            if (durationParts.length === 3) durationSec = durationParts[0]*3600 + durationParts[1]*60 + durationParts[2];
            else if (durationParts.length === 2) durationSec = durationParts[0]*60 + durationParts[1];
            else durationSec = durationParts[0] || 0;

            songs.push({ id, title, artist, album: query, duration: durationSec, cover_url: thumb, web_url: `https://www.youtube.com/watch?v=${id}` });
            if (songs.length >= limit) break;
          }
          resolve(songs);
        } catch (e) {
          resolve([]);
        }
      });
    });
    req.on('error', () => resolve([]));
    req.setTimeout(15000, () => { req.destroy(); resolve([]); });
    req.end();
  });
}

function getStreamUrl(videoId) {
  return new Promise((resolve, reject) => {
    try {
      const info = ytdl.getInfo(videoId);
      info.then(data => {
        const format = ytdl.chooseFormat(data.formats, { quality: 'highestaudio', filter: 'audioonly' });
        resolve(format.url);
      }).catch(err => {
        reject(err);
      });
    } catch (e) {
      reject(e);
    }
  });
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
    jsonResponse(res, 200, { status: 'ok', engine: 'ytdl-core' });
    return;
  }

  if (parsed.pathname === '/search') {
    const query = params.q || '';
    const limit = parseInt(params.limit) || 20;
    if (!query) {
      jsonResponse(res, 400, { error: 'query required' });
      return;
    }

    const cacheKey = `${query}:${limit}`;
    if (searchCache.has(cacheKey)) {
      jsonResponse(res, 200, searchCache.get(cacheKey));
      return;
    }

    try {
      const songs = await YouTubeSearch(query, limit);
      const data = { songs, total: songs.length };
      searchCache.set(cacheKey, data);
      if (searchCache.size > 200) {
        const firstKey = searchCache.keys().next().value;
        searchCache.delete(firstKey);
      }

      for (const s of songs.slice(0, 5)) {
        if (!streamCache.has(s.id)) {
          getStreamUrl(s.id).then(url => {
            streamCache.set(s.id, url);
          }).catch(() => {});
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
    if (!videoId) {
      jsonResponse(res, 400, { error: 'id required' });
      return;
    }

    if (streamCache.has(videoId)) {
      jsonResponse(res, 200, { stream_url: streamCache.get(videoId) });
      return;
    }

    try {
      const streamUrl = await getStreamUrl(videoId);
      streamCache.set(videoId, streamUrl);
      jsonResponse(res, 200, { stream_url: streamUrl });
    } catch (e) {
      jsonResponse(res, 500, { error: 'could not get stream', details: e.message });
    }
    return;
  }

  jsonResponse(res, 404, { error: 'not found' });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Music API Server running on port ${PORT}`);
});
