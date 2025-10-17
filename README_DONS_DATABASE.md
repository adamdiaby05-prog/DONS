# 🗄️ Configuration Base de Données Dons sur Dokploy

## Configuration de la base de données

Votre base de données PostgreSQL a été créée avec les paramètres suivants :

- **Name** : `database`
- **App Name** : `dons-database`
- **Database Name** : `Dons`
- **Database User** : `postgres`
- **Docker image** : `postgres:15`

## 🔧 Variables d'environnement pour Dokploy

### Variables obligatoires :
```yaml
# Application
APP_NAME=DONS
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-domaine.com
APP_KEY=base64:your-generated-app-key

# Base de données PostgreSQL
DB_CONNECTION=pgsql
DB_HOST=dons-database
DB_PORT=5432
DB_DATABASE=Dons
DB_USERNAME=postgres
DB_PASSWORD=your_postgres_password
```

### Variables optionnelles :
```yaml
# Logs
LOG_CHANNEL=stack
LOG_LEVEL=debug

# Cache et Sessions
CACHE_DRIVER=file
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Mail (optionnel)
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_FROM_ADDRESS="hello@dons.com"
MAIL_FROM_NAME="DONS"
```

## 🚀 Déploiement sur Dokploy

### 1. Configuration de l'application

1. **Accédez à votre dashboard** : [http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4](http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4)

2. **Créez une nouvelle application** :
   - **Nom** : `dons-app`
   - **Type** : `Docker`
   - **Repository** : `https://github.com/adamdiaby05-prog/DONS.git`
   - **Branch** : `master`
   - **Dockerfile** : `Dockerfile`

### 2. Liaison avec la base de données

1. **Liez votre base de données** :
   - Sélectionnez la base `dons-database` créée
   - Les variables d'environnement seront automatiquement configurées

2. **Variables d'environnement personnalisées** :
   ```yaml
   APP_KEY=base64:your-generated-app-key
   APP_URL=https://votre-domaine.com
   ```

### 3. Script de déploiement automatique

Le projet inclut un script de déploiement qui :
- Exécute les migrations Laravel
- Crée les tables nécessaires
- Insère les données de test
- Optimise l'application

```bash
# Exécuter les migrations
php artisan migrate --force

# Créer les tables et données de test
php artisan migrate:fresh --seed

# Optimiser l'application
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 📊 Structure de la base de données

### Tables principales :
- `users` - Utilisateurs du système
- `groups` - Groupes de contribution
- `group_members` - Membres des groupes
- `contributions` - Contributions des membres
- `payments` - Paiements Barapay
- `notifications` - Notifications système

### Migrations incluses :
- ✅ Création des tables utilisateurs
- ✅ Création des groupes et membres
- ✅ Système de contributions
- ✅ Intégration des paiements
- ✅ Système de notifications

## 🔍 Test de connexion

### Script de test inclus :
```bash
# Exécuter le test de connexion
php test-db-connection.php
```

### Vérification manuelle :
```bash
# Dans le conteneur de l'application
php artisan tinker
>>> DB::connection()->getPdo();
```

## 🛠️ Dépannage

### Problèmes courants :

1. **Erreur de connexion PostgreSQL** :
   - Vérifiez que la base de données `dons-database` est démarrée
   - Vérifiez les variables d'environnement
   - Vérifiez les permissions

2. **Erreur de migration** :
   ```bash
   php artisan migrate:reset
   php artisan migrate --force
   ```

3. **Problème de permissions** :
   ```bash
   chmod -R 755 storage/
   chmod -R 755 bootstrap/cache/
   ```

### Logs utiles :
```bash
# Logs de l'application
docker logs dons-app

# Logs de la base de données
docker logs dons-database

# Vérifier les services
docker ps
```

## 🔐 Sécurité

1. **Changez le mot de passe PostgreSQL par défaut**
2. **Utilisez HTTPS en production**
3. **Configurez un firewall**
4. **Sauvegardez régulièrement la base de données**

### Sauvegarde PostgreSQL :
```bash
# Sauvegarde
pg_dump -h dons-database -U postgres -d Dons > backup.sql

# Restauration
psql -h dons-database -U postgres -d Dons < backup.sql
```

## 📈 Monitoring

### Métriques importantes :
- Connexions à la base de données
- Performance des requêtes
- Espace disque
- Utilisation mémoire

### Outils recommandés :
- **pgAdmin** pour l'administration PostgreSQL
- **Laravel Telescope** pour le debugging
- **Laravel Horizon** pour les queues

## 🎯 Prochaines étapes

1. **Déployez l'application** sur Dokploy
2. **Liez la base de données** `dons-database`
3. **Configurez les variables** d'environnement
4. **Testez la connexion** avec le script fourni
5. **Exécutez les migrations** Laravel
6. **Vérifiez l'application** déployée

## 📁 Fichiers de configuration

- `dokploy-dons-database.yml` - Configuration optimisée pour la base `Dons`
- `test-db-connection.php` - Script de test de connexion
- `backend/env.production` - Variables d'environnement
- `README_DONS_DATABASE.md` - Ce guide

Votre application DONS est maintenant configurée pour utiliser la base de données `Dons` sur Dokploy ! 🚀
