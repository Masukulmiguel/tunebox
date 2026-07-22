import http.server
import socketserver
import urllib.request
import urllib.parse
import sys
import ssl

PORT = 9090

class ThreadedHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        raw_query = parsed.query

        if not raw_query:
            self._send_error(400)
            return

        target_url = urllib.parse.unquote(raw_query)

        if not target_url.startswith('http'):
            self._send_error(400)
            return

        try:
            ctx = ssl.create_default_context()
            req = urllib.request.Request(target_url)
            req.add_header('User-Agent', 'Mozilla/5.0')

            with urllib.request.urlopen(req, timeout=15, context=ctx) as response:
                data = response.read()
                content_type = response.headers.get('Content-Type', 'application/json')

                self.send_response(200)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Type', content_type)
                self.send_header('Cache-Control', 'public, max-age=300')
                self.end_headers()
                self.wfile.write(data)
        except Exception as e:
            self._send_error(502)

    def _send_error(self, code):
        self.send_response(code)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{}')

    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    server = ThreadedHTTPServer(('127.0.0.1', PORT), ProxyHandler)
    print(f'Proxy running on http://127.0.0.1:{PORT}')
    sys.stdout.flush()
    server.serve_forever()
