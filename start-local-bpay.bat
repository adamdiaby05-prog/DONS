@echo off
echo 💳 Démarrage du BPay SDK en local...
echo.

echo 📋 Copie des fichiers BPay...
if not exist "bpay-local" mkdir bpay-local

copy "Nouveau dossier\paymoney_sdk(1)\bpay_sdk\php\*" bpay-local\ /Y
copy barapay_payment_integration.php bpay-local\
copy api_payments_*.php bpay-local\
copy payment_*.php bpay-local\
copy test_*.php bpay-local\

cd bpay-local

echo 🔧 Installation des dépendances Composer...
if exist composer.json (
    composer install --ignore-platform-reqs --no-dev
)

echo 🚀 Démarrage du serveur BPay...
echo 📍 BPay SDK disponible sur: http://localhost:8080
echo 📍 Test BPay: http://localhost:8080/test_barapay_integration.php
echo 📍 Intégration: http://localhost:8080/barapay_payment_integration.php
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

php -S 0.0.0.0:8080
