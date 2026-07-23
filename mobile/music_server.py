import http.server
import json
import subprocess
import os
import sys
import urllib.parse
import threading
import time
import random

PORT = 9090
YTDLP_PATH = os.environ.get("YTDLP_PATH", "yt-dlp")

search_cache = {}
stream_cache = {}
cache_lock = threading.Lock()

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
]


class MusicHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def _set_cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")

    def do_OPTIONS(self):
        self.send_response(204)
        self._set_cors()
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)

        if parsed.path == "/search":
            self.handle_search(params)
        elif parsed.path == "/stream":
            self.handle_stream(params)
        elif parsed.path == "/health":
            self.send_response(200)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode())
        else:
            self.send_response(404)
            self._set_cors()
            self.end_headers()

    def handle_search(self, params):
        query = params.get("q", [""])[0]
        limit = int(params.get("limit", ["20"])[0])

        if not query:
            self.send_response(400)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "query required"}).encode())
            return

        cache_key = f"{query}:{limit}"
        with cache_lock:
            if cache_key in search_cache:
                cached = search_cache[cache_key]
                self.send_response(200)
                self._set_cors()
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(cached).encode())
                return

        try:
            search_url = f"ytsearch{limit}:{query}"
            ua = random.choice(USER_AGENTS)
            cmd = [
                YTDLP_PATH,
                "--js-runtimes", "nodejs",
                "--dump-json",
                "--flat-playlist",
                "--no-download",
                "--user-agent", ua,
                "--extractor-args", "youtube:player_client=web,android",
                search_url
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
            )

            if result.returncode != 0:
                self.send_response(500)
                self._set_cors()
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "search failed", "details": result.stderr[:300]}).encode())
                return

            songs = []
            for line in result.stdout.strip().split("\n"):
                if not line.strip():
                    continue
                try:
                    data = json.loads(line)
                    duration = data.get("duration") or 0
                    thumbnails = data.get("thumbnails", [])
                    thumb_url = ""
                    if thumbnails:
                        thumb_url = thumbnails[-1].get("url", "") if isinstance(thumbnails[-1], dict) else str(thumbnails[-1])

                    songs.append({
                        "id": data.get("id", ""),
                        "title": data.get("title", ""),
                        "artist": data.get("channel", data.get("uploader", "Unknown")),
                        "album": data.get("playlist_title", ""),
                        "duration": int(duration) if duration else 0,
                        "cover_url": thumb_url,
                        "web_url": data.get("url", f"https://www.youtube.com/watch?v={data.get('id', '')}")
                    })
                except json.JSONDecodeError:
                    continue

            response_data = {"songs": songs, "total": len(songs)}

            with cache_lock:
                search_cache[cache_key] = response_data
                if len(search_cache) > 200:
                    oldest = list(search_cache.keys())[0]
                    del search_cache[oldest]

            self.send_response(200)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode())

        except subprocess.TimeoutExpired:
            self.send_response(504)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "search timeout"}).encode())
        except Exception as e:
            self.send_response(500)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())

    def handle_stream(self, params):
        video_id = params.get("id", [""])[0]
        if not video_id:
            self.send_response(400)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "id required"}).encode())
            return

        with cache_lock:
            if video_id in stream_cache:
                self.send_response(200)
                self._set_cors()
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"stream_url": stream_cache[video_id]}).encode())
                return

        try:
            video_url = f"https://www.youtube.com/watch?v={video_id}"
            ua = random.choice(USER_AGENTS)

            for attempt in range(3):
                cmd = [
                    YTDLP_PATH,
                    "--js-runtimes", "nodejs",
                    "-f", "bestaudio[ext=m4a]/bestaudio/best",
                    "-g",
                    "--no-download",
                    "--user-agent", ua,
                    "--extractor-args", "youtube:player_client=web,android",
                    video_url
                ]

                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=20,
                )

                if result.returncode == 0 and result.stdout.strip():
                    stream_url = result.stdout.strip().split("\n")[0]
                    with cache_lock:
                        stream_cache[video_id] = stream_url
                    self.send_response(200)
                    self._set_cors()
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"stream_url": stream_url}).encode())
                    return

                if "429" in result.stderr:
                    time.sleep(1 + attempt)
                    ua = random.choice(USER_AGENTS)
                    continue
                break

            self.send_response(500)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "could not get stream", "details": result.stderr[:300]}).encode())

        except subprocess.TimeoutExpired:
            self.send_response(504)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "stream timeout"}).encode())
        except Exception as e:
            self.send_response(500)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())


if __name__ == "__main__":
    PORT = int(os.environ.get("PORT", PORT))
    HOST = "0.0.0.0"
    server = http.server.HTTPServer((HOST, PORT), MusicHandler)
    print(f"Music API Server running on http://{HOST}:{PORT}")
    print("Endpoints:")
    print("  GET /search?q=<query>&limit=20 - Search YouTube Music")
    print("  GET /stream?id=<video_id> - Get stream URL for a video")
    print("  GET /health - Health check")
    server.serve_forever()
