@echo off
echo 🎯 Démarrage du Frontend Flutter DONS en local...
echo.

cd frontend

echo 📋 Vérification des dépendances Flutter...
flutter doctor

echo 🔧 Installation des dépendances...
flutter pub get

echo 🏗️  Build de l'application Flutter...
flutter build web --release --web-renderer html

echo 🚀 Démarrage du serveur frontend...
echo 📍 Frontend disponible sur: http://localhost:3000
echo 📍 Dashboard: http://localhost:3000/dashboard.html
echo 📍 Login: http://localhost:3000/login.html
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

cd build/web
python static-server.py
