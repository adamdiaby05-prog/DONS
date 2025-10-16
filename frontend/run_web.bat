@echo off
echo Démarrage de l'application web DONS...
echo.

REM Vérifier si Flutter est installé
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Erreur: Flutter n'est pas installé ou pas dans le PATH
    echo Veuillez installer Flutter et l'ajouter au PATH
    pause
    exit /b 1
)

REM Obtenir les dépendances
echo Installation des dépendances...
flutter pub get

REM Démarrer le serveur de développement web
echo Démarrage du serveur de développement...
echo L'application sera disponible sur http://192.168.100.7:3000
echo.
echo Accès depuis votre téléphone: http://192.168.100.7:3000
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0

pause
