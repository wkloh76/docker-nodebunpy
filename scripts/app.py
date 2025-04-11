from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(b"Hello from Python Server!")

server = HTTPServer(("", 3001), SimpleHandler)
print("Dummy Server running at http://localhost:3001")
server.serve_forever()
