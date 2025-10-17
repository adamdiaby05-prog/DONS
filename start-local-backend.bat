@echo off
echo 🚀 Démarrage du Backend Laravel DONS en local...
echo.

cd backend

echo 📋 Vérification des dépendances...
if not exist vendor (
    echo ⚠️  Installation des dépendances Composer...
    composer install --ignore-platform-reqs
)

echo 🔧 Configuration de l'environnement...
if not exist .env (
    copy env.production .env
    echo ✅ Fichier .env créé
)

echo 🔑 Génération de la clé d'application...
php artisan key:generate

echo 🗄️  Configuration de la base de données...
echo ⚠️  Assurez-vous que PostgreSQL est démarré et configuré

echo 🚀 Démarrage du serveur Laravel...
echo 📍 Backend disponible sur: http://localhost:8000
echo 📍 API disponible sur: http://localhost:8000/api
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

php artisan serve --host=0.0.0.0 --port=8000
