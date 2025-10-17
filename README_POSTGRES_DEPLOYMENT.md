# 🐘 Déploiement DONS avec PostgreSQL sur Dokploy

## Configuration PostgreSQL sur Dokploy

Votre base de données PostgreSQL a été créée avec les paramètres suivants :
- **Nom** : `Dons`
- **App Name** : `dons-dons`
- **Database Name** : `dons`
- **Database User** : `postgres`
- **Docker image** : `postgres:15`

## 🔧 Variables d'environnement à configurer dans Dokploy

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
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=dons
DB_USERNAME=postgres
DB_PASSWORD=your_postgres_password

# Cache et Sessions
CACHE_DRIVER=file
SESSION_DRIVER=file
SESSION_LIFETIME=120
```

### Variables optionnelles :
```yaml
# Logs
LOG_CHANNEL=stack
LOG_LEVEL=debug

# Mail (optionnel)
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_FROM_ADDRESS="hello@dons.com"
MAIL_FROM_NAME="DONS"
```

## 🚀 Étapes de déploiement

### 1. Configuration de l'application sur Dokploy

1. **Accédez à votre dashboard** : [http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4](http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4)

2. **Créez une nouvelle application** :
   - **Nom** : `dons-app`
   - **Type** : `Docker`
   - **Repository** : `https://github.com/adamdiaby05-prog/DONS.git`
   - **Branch** : `master`
   - **Dockerfile** : `Dockerfile`

### 2. Configuration de la base de données

1. **Liez votre base de données PostgreSQL** :
   - Sélectionnez la base de données `dons-dons` créée
   - Les variables d'environnement seront automatiquement configurées

2. **Variables d'environnement personnalisées** :
   ```yaml
   APP_KEY=base64:your-generated-app-key
   APP_URL=https://votre-domaine.com
   ```

### 3. Script de déploiement

Le projet inclut un script de déploiement automatique :

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

## 🔍 Vérification du déploiement

### 1. Vérifier la connexion à la base de données
```bash
# Dans le conteneur de l'application
php artisan tinker
>>> DB::connection()->getPdo();
```

### 2. Vérifier les migrations
```bash
php artisan migrate:status
```

### 3. Tester l'API
```bash
# Test de l'API
curl -X GET http://votre-domaine.com/api/health
```

## 🛠️ Dépannage

### Problèmes courants :

1. **Erreur de connexion PostgreSQL** :
   - Vérifiez que la base de données est démarrée
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

# Logs de PostgreSQL
docker logs postgres

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
pg_dump -h postgres -U postgres -d dons > backup.sql

# Restauration
psql -h postgres -U postgres -d dons < backup.sql
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
2. **Configurez le domaine** personnalisé
3. **Testez toutes les fonctionnalités**
4. **Configurez les sauvegardes** automatiques
5. **Mettez en place le monitoring**

Votre application DONS est maintenant prête pour le déploiement avec PostgreSQL ! 🚀
