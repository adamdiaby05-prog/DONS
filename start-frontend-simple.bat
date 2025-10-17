@echo off
echo 🎯 Démarrage du Frontend DONS en local...
echo.

cd frontend\web

echo 🚀 Démarrage du serveur HTTP simple...
echo 📍 Frontend disponible sur: http://localhost:3000
echo 📍 Dashboard: http://localhost:3000/dashboard.html
echo 📍 Login: http://localhost:3000/login.html
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

py -m http.server 3000
