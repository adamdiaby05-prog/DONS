@echo off
REM Script de déploiement pour DONS sur Dokploy (Windows)
echo 🚀 Déploiement de DONS sur Dokploy...

REM Vérifier que nous sommes dans le bon répertoire
if not exist "Dockerfile" (
    echo ❌ Erreur: Dockerfile non trouvé. Assurez-vous d'être dans le répertoire racine du projet.
    pause
    exit /b 1
)

REM Créer le fichier .env de production si il n'existe pas
if not exist "backend\.env" (
    echo 📝 Création du fichier .env de production...
    copy "backend\env.production" "backend\.env"
    echo ✅ Fichier .env créé
)

REM Créer la base de données SQLite si elle n'existe pas
if not exist "backend\database\database.sqlite" (
    echo 🗄️ Création de la base de données SQLite...
    echo. > "backend\database\database.sqlite"
)

echo ✅ Déploiement préparé avec succès!
echo.
echo 📋 Prochaines étapes:
echo 1. Poussez les changements vers GitHub: git add . ^&^& git commit -m "Ajout configuration Dokploy" ^&^& git push
echo 2. Connectez-vous à votre dashboard Dokploy
echo 3. Créez une nouvelle application avec le repository GitHub
echo 4. Configurez les variables d'environnement
echo 5. Déployez l'application
echo.
echo 🔗 Dashboard Dokploy: http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4
pause
