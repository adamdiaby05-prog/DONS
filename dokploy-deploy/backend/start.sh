#!/bin/bash

# Script de démarrage pour Dokploy
echo "🚀 Démarrage de l'API DONS Backend..."

# Vérifier que PHP est installé
if ! command -v php &> /dev/null; then
    echo "❌ PHP n'est pas installé"
    exit 1
fi

# Installer les dépendances Composer si nécessaire
if [ -f "composer.json" ]; then
    echo "📦 Installation des dépendances Composer..."
    composer install --no-dev --optimize-autoloader
fi

# Démarrer le serveur PHP
echo "🌐 Démarrage du serveur PHP sur le port 8000..."
php -S 0.0.0.0:8000 -t .

echo "✅ API DONS Backend démarrée avec succès!"
echo "📍 URL: http://0.0.0.0:8000"
echo "🔗 Endpoints disponibles:"
echo "   - POST /api_save_payment_simple.php"
echo "   - GET /api_payments_status.php"
echo "   - GET /api_payments_history.php"
