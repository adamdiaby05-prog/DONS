@echo off
echo Construction de l'application web DONS...
echo.

REM Nettoyer les builds précédents
echo Nettoyage des builds précédents...
flutter clean

REM Obtenir les dépendances
echo Installation des dépendances...
flutter pub get

REM Construire pour le web
echo Construction pour le web...
flutter build web --release --web-renderer html

echo.
echo Construction terminée !
echo L'application web est disponible dans le dossier build/web/
echo.
echo Pour tester l'application :
echo 1. Démarrez le serveur backend Laravel
echo 2. Ouvrez build/web/index.html dans votre navigateur
echo.
pause




