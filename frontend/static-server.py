#!/usr/bin/env python3
"""
Serveur statique pour l'application DONS Frontend
Sert les fichiers Flutter et les fichiers statiques du projet
"""

import http.server
import socketserver
import os
import sys
from urllib.parse import urlparse

class DONSStaticHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.getcwd(), **kwargs)
    
    def do_GET(self):
        # Router pour gérer les routes Flutter
        if self.path == '/' or self.path == '/index.html':
            self.path = '/index.html'
        elif not self.path.startswith('/assets/') and not self.path.startswith('/icons/') and '.' not in self.path:
            # Route Flutter - rediriger vers index.html
            self.path = '/index.html'
        
        return super().do_GET()
    
    def end_headers(self):
        # Headers pour Flutter web
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

if __name__ == "__main__":
    PORT = int(os.environ.get('PORT', 80))
    
    with socketserver.TCPServer(("", PORT), DONSStaticHandler) as httpd:
        print(f"🚀 Serveur DONS Frontend démarré sur le port {PORT}")
        print(f"📁 Répertoire: {os.getcwd()}")
        httpd.serve_forever()
