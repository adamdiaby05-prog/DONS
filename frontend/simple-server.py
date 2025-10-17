#!/usr/bin/env python3
"""
Serveur HTTP simple pour l'application DONS Frontend
"""

import http.server
import socketserver
import os
import sys
from urllib.parse import urlparse

class DONSHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.getcwd(), **kwargs)
    
    def do_GET(self):
        # Router pour gérer les routes
        if self.path == '/' or self.path == '/index.html':
            self.path = '/index.html'
        elif not self.path.startswith('/assets/') and not self.path.startswith('/icons/') and '.' not in self.path:
            # Route Flutter - rediriger vers index.html
            self.path = '/index.html'
        
        return super().do_GET()
    
    def end_headers(self):
        # Headers CORS pour permettre les appels API
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

if __name__ == "__main__":
    PORT = 3000
    
    # Changer vers le dossier web
    web_dir = os.path.join(os.path.dirname(__file__), 'web')
    os.chdir(web_dir)
    
    with socketserver.TCPServer(("", PORT), DONSHandler) as httpd:
        print(f"🚀 Serveur DONS Frontend démarré sur le port {PORT}")
        print(f"📁 Répertoire: {os.getcwd()}")
        print(f"🌐 URL: http://localhost:{PORT}")
        print("Appuyez sur Ctrl+C pour arrêter le serveur")
        httpd.serve_forever()
