#!/bin/bash
# Script de build Flutter pour le web

echo "🚀 Démarrage du build Flutter pour le web..."

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi

# Installer les dépendances
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Build pour le web
echo "🔨 Build Flutter pour le web..."
flutter build web --release --web-renderer html

echo "✅ Build Flutter terminé !"
echo "📁 Fichiers générés dans: build/web/"
