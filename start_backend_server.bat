@echo off
echo ========================================
echo  Serveur Backend DONS
echo ========================================
echo.
echo Serveur accessible sur:
echo - http://localhost:8000
echo - http://192.168.234.148:8000
echo.
echo Appuyez sur Ctrl+C pour arreter
echo.

cd backend
php -S 0.0.0.0:8000 -t . working_api.php

pause


