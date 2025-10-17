@echo off
REM Script de configuration de la base de données DONS (Windows)
echo 🚀 Configuration de la base de données DONS...

REM Variables d'environnement
set DB_HOST=dons-database-ysb0io
set DB_PORT=5432
set DB_NAME=Dons
set DB_USER=postgres
set DB_PASSWORD=9vx4rsve50bkmekz

echo 📊 Connexion à la base de données...
echo Host: %DB_HOST%
echo Database: %DB_NAME%
echo User: %DB_USER%

REM Vérifier si psql est disponible
where psql >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ PostgreSQL client (psql) non trouvé
    echo 🔧 Installez PostgreSQL ou ajoutez psql au PATH
    pause
    exit /b 1
)

REM Attendre que PostgreSQL soit prêt
echo ⏳ Attente de PostgreSQL...
:wait_loop
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT 1;" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo PostgreSQL n'est pas encore prêt...
    timeout /t 2 /nobreak >nul
    goto wait_loop
)

echo ✅ PostgreSQL est prêt !

REM Exécuter le script SQL
echo 📝 Exécution du script SQL...
set PGPASSWORD=%DB_PASSWORD%
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f create-tables.sql

if %ERRORLEVEL% EQU 0 (
    echo 🎉 Base de données DONS configurée avec succès !
    echo 📊 Tables créées :
    psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
) else (
    echo ❌ Erreur lors de la configuration de la base de données
    pause
    exit /b 1
)

echo.
echo 🚀 La base de données DONS est maintenant prête !
pause
