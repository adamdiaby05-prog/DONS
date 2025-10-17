#!/bin/bash

# Script de déploiement pour DONS sur Dokploy
echo "🚀 Déploiement de DONS sur Dokploy..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "Dockerfile" ]; then
    echo "❌ Erreur: Dockerfile non trouvé. Assurez-vous d'être dans le répertoire racine du projet."
    exit 1
fi

# Créer le fichier .env de production si il n'existe pas
if [ ! -f "backend/.env" ]; then
    echo "📝 Création du fichier .env de production..."
    cp backend/env.production backend/.env
    echo "✅ Fichier .env créé"
fi

# Générer une clé d'application Laravel
echo "🔑 Génération de la clé d'application..."
cd backend
php artisan key:generate --force
cd ..

# Créer la base de données SQLite si elle n'existe pas
if [ ! -f "backend/database/database.sqlite" ]; then
    echo "🗄️ Création de la base de données SQLite..."
    touch backend/database/database.sqlite
    chmod 664 backend/database/database.sqlite
fi

# Exécuter les migrations
echo "📊 Exécution des migrations..."
cd backend
php artisan migrate --force
cd ..

# Construire les assets frontend
echo "🎨 Construction des assets frontend..."
cd frontend
npm install
npm run build
cd ..

echo "✅ Déploiement préparé avec succès!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Poussez les changements vers GitHub: git add . && git commit -m 'Ajout configuration Dokploy' && git push"
echo "2. Connectez-vous à votre dashboard Dokploy"
echo "3. Créez une nouvelle application avec le repository GitHub"
echo "4. Configurez les variables d'environnement"
echo "5. Déployez l'application"
echo ""
echo "🔗 Dashboard Dokploy: http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4"
