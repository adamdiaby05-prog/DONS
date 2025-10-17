@echo off
echo ========================================
echo  Application Flutter Web DONS
echo ========================================
echo.
echo Application sera accessible sur:
echo - http://localhost:3000
echo.
echo Backend configure sur:
echo - http://192.168.234.148:8000
echo.
echo Compilation en cours...
echo.

cd frontend
flutter run -d chrome --web-port 3000

pause


