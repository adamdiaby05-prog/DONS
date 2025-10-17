#!/bin/bash

# Script de déploiement statique pour Flutter Web
echo "🚀 Déploiement statique de l'application Flutter DONS..."

# Vérifier que nous sommes dans le bon répertoire
echo "📁 Répertoire actuel: $(pwd)"
echo "📋 Contenu du répertoire:"
ls -la

# Vérifier que pubspec.yaml existe
if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml trouvé"
    echo "📄 Contenu de pubspec.yaml:"
    head -5 pubspec.yaml
else
    echo "❌ pubspec.yaml non trouvé"
    exit 1
fi

# Installer les dépendances Flutter
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Construire l'application Flutter pour le web
echo "🔨 Construction de l'application Flutter..."
flutter build web --release

# Vérifier que le build a été créé
if [ -d "build/web" ]; then
    echo "✅ Build Flutter créé avec succès"
    echo "📁 Contenu du build:"
    ls -la build/web/
else
    echo "❌ Build Flutter non créé"
    exit 1
fi

# Démarrer le serveur
echo "🌐 Démarrage du serveur sur le port 3000..."
cd build/web
python3 -m http.server 3000
