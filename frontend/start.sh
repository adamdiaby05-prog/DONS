#!/bin/bash

echo "🚀 Démarrage du Frontend Flutter DONS..."

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi

# Aller dans le dossier frontend
cd /app/frontend

# Installer les dépendances
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Construire l'application
echo "🔨 Construction de l'application Flutter..."
flutter build web --release

# Démarrer le serveur
echo "🌐 Démarrage du serveur sur le port 3000..."
cd build/web
python3 -m http.server 3000
