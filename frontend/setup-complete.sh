#!/bin/bash
# Script de configuration complète pour le frontend DONS

echo "🚀 Configuration du frontend DONS..."

# Créer le répertoire de build
mkdir -p build/web

# Copier les fichiers Flutter
echo "📦 Copie des fichiers Flutter..."
cp -r . build/web/

# Copier les fichiers statiques du projet
echo "📁 Copie des fichiers statiques..."
mkdir -p build/web/static

# Copier les fichiers PHP (pour référence)
cp ../*.php build/web/static/ 2>/dev/null || true
cp ../api_*.php build/web/static/ 2>/dev/null || true
cp ../payment*.php build/web/static/ 2>/dev/null || true
cp ../test_*.php build/web/static/ 2>/dev/null || true

# Copier les fichiers de documentation
cp ../*.md build/web/static/ 2>/dev/null || true

# Copier les scripts SQL
cp ../*.sql build/web/static/ 2>/dev/null || true

# Copier les fichiers de configuration
cp ../*.yml build/web/static/ 2>/dev/null || true
cp ../*.yaml build/web/static/ 2>/dev/null || true

echo "✅ Configuration terminée !"
echo "📁 Fichiers disponibles dans: build/web/"
