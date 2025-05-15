#!/usr/bin/env python
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

def root(*args, **kwargs):
    return "root"


def apicall(*args, **kwargs):
    return "apicall"


def register(*args, **kwargs):
    return "register"


ROUTES = {
    "/": ("GET", root),
    "/decrypt_commitment": ("GET", apicall),
    "/get_data_for_encryption": ("GET", apicall),
    "/get_decryption_key": ("GET", apicall),
    "/register_identity": ("POST", register),
}


def route(server):
    method, fn = ROUTES.get(server.path, (None, None))
    return method, fn


class Server(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()

    def do_GET(self):
        method, fn = route(self)
        if method != "GET":
            self.wfile.write(b'{"error": "error"}')
            return
        self._set_headers()
        self.wfile.write(json.dumps({"result": fn()}).encode())

    def do_POST(self):
        method, fn = route(self)
        if method != "POST":
            self.wfile.write(b'{"error": "error"}')
            return
        message = {"received": fn()}

        self._set_headers()
        self.wfile.write(json.dumps(message).encode())


def run(server_class=HTTPServer, handler_class=Server, port=8008):
    server_address = ("0.0.0.0", port)
    httpd = server_class(server_address, handler_class)

    print("Starting httpd on port %d..." % port, flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    print("api running", flush=True)
    run()
