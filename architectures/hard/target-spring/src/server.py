from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import os
import subprocess

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Simulation d'une page d'erreur Spring Boot "Whitelabel Error Page"
        # La faille : Un paramètre caché '?cmd=' qui exécute des commandes
        
        parsed_path = urllib.parse.urlparse(self.path)
        query_params = urllib.parse.parse_qs(parsed_path.query)

        # FAILLE RCE ICI
        if 'cmd' in query_params:
            cmd = query_params['cmd'][0]
            try:
                # Exécution aveugle de la commande
                output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(output)
                return
            except Exception as e:
                pass

        # Page par défaut "Hello World"
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        html = """
        <html>
        <head><title>Hello World Application</title></head>
        <body>
            <h1>Hello World!</h1>
            <p>Welcome to my first Spring Boot application.</p>
            <p>Status: All systems operational.</p>
            </body>
        </html>
        """
        self.wfile.write(html.encode('utf-8'))

def run(server_class=HTTPServer, handler_class=SimpleHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting httpd on port {port}...')
    httpd.serve_forever()

if __name__ == "__main__":
    run()
