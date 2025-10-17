@echo off
echo Demarrage du serveur de test pour Flutter...
echo.
echo Le serveur sera accessible sur: http://localhost:8000
echo.
echo Pour tester la connexion:
echo - GET: http://localhost:8000/test_simple.php
echo - POST: http://localhost:8000/test_simple.php (avec JSON)
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.
php -S 0.0.0.0:8000 test_simple.php
