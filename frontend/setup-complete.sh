#!/bin/bash
# Script de configuration complète pour le frontend DONS

echo "🚀 Configuration du frontend DONS..."

# Créer le répertoire de build
mkdir -p build/web

# Copier les fichiers Flutter (si build existe)
if [ -d "build/web" ]; then
    echo "📦 Copie des fichiers Flutter buildés..."
    cp -r build/web/* build/web/ 2>/dev/null || true
else
    echo "📦 Création des fichiers Flutter de base..."
    # Créer un index.html basique si Flutter n'est pas buildé
    cat > build/web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>DONS - Système de gestion de cotisations</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { text-align: center; color: #2c3e50; }
        .content { margin: 20px 0; }
        .api-link { display: inline-block; margin: 10px; padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 5px; }
        .api-link:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 DONS - Système de gestion de cotisations</h1>
        <div class="content">
            <p>Bienvenue dans l'application DONS !</p>
            <p>Cette interface vous permet de gérer les cotisations pour vos groupes et associations.</p>
            
            <h2>🔗 Liens utiles :</h2>
            <a href="/api" class="api-link">API Backend</a>
            <a href="/static/" class="api-link">Fichiers statiques</a>
            <a href="/static/README_DEPLOYMENT.md" class="api-link">Documentation</a>
            
            <h2>📋 Fonctionnalités :</h2>
            <ul>
                <li>Gestion des groupes</li>
                <li>Suivi des cotisations</li>
                <li>Paiements sécurisés</li>
                <li>Tableau de bord administrateur</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF
fi

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
