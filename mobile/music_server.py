import http.server
import json
import subprocess
import os
import sys
import urllib.parse
import threading
import re

PORT = 9090
YTDLP_PATH = r"C:\Users\fmlid\AppData\Roaming\Python\Python313\Scripts\yt-dlp.exe"

search_cache = {}
stream_cache = {}
cache_lock = threading.Lock()

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
        page = int(params.get("page", ["1"])[0])

        if not query:
            self.send_response(400)
            self._set_cors()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "query required"}).encode())
            return

        cache_key = f"{query}:{limit}:{page}"
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
            cmd = [
                YTDLP_PATH,
                "--dump-json",
                "--flat-playlist",
                "--no-download",
                search_url
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                creationflags=subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0
            )

            if result.returncode != 0:
                self.send_response(500)
                self._set_cors()
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "search failed", "details": result.stderr[:200]}).encode())
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
                if len(search_cache) > 100:
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
            cmd = [
                YTDLP_PATH,
                "-f", "bestaudio[ext=m4a]/bestaudio/best",
                "-g",
                "--no-download",
                video_url
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=15,
                creationflags=subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0
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
            else:
                self.send_response(500)
                self._set_cors()
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "could not get stream", "details": result.stderr[:200]}).encode())

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
    server = http.server.HTTPServer(("127.0.0.1", PORT), MusicHandler)
    print(f"Music API Server running on http://127.0.0.1:{PORT}")
    print("Endpoints:")
    print("  GET /search?q=<query>&limit=20 - Search YouTube Music")
    print("  GET /stream?id=<video_id> - Get stream URL for a video")
    print("  GET /health - Health check")
    server.serve_forever()
