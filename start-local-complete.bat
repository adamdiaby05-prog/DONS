@echo off
echo 🌟 Démarrage complet du système DONS en local...
echo.

echo 📋 Vérification des prérequis...
echo ✅ PHP: 
php --version
echo ✅ Composer: 
composer --version
echo ✅ Flutter: 
flutter --version
echo ✅ Python: 
python --version
echo.

echo 🚀 Démarrage en arrière-plan...
echo.

echo 🔧 Démarrage du Backend Laravel...
start "Backend DONS" cmd /k "start-local-backend.bat"

timeout /t 5 /nobreak > nul

echo 🎯 Démarrage du Frontend Flutter...
start "Frontend DONS" cmd /k "start-local-frontend.bat"

echo.
echo ✅ Système DONS démarré !
echo.
echo 📍 URLs disponibles:
echo   🔧 Backend Laravel: http://localhost:8000
echo   🎯 Frontend Flutter: http://localhost:3000
echo   📊 API Dons: http://localhost:8000/api/dons
echo   💳 API Paiements: http://localhost:8000/api/payments
echo   🔗 BPay: http://localhost:8000/barapay_payment_integration.php
echo.
echo Appuyez sur une touche pour arrêter tous les services...
pause > nul

echo 🛑 Arrêt des services...
taskkill /f /im php.exe 2>nul
taskkill /f /im python.exe 2>nul
echo ✅ Services arrêtés
