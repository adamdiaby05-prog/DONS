# Guide de Déploiement DONS sur Dokploy

## 🚀 Déploiement sur Dokploy

### Prérequis
- Compte Dokploy configuré
- Accès à votre repository GitHub
- Docker installé (optionnel pour test local)

### Étapes de déploiement

#### 1. Configuration du projet sur Dokploy

1. **Connectez-vous à votre dashboard Dokploy** : [http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4](http://213.199.48.58:3000/dashboard/project/vXfo-DaAkRLXg7mHsYlmS/environment/QEqR4iWpuExOSkB7m7cG4)

2. **Créer une nouvelle application** :
   - Nom : `dons-app`
   - Type : `Docker`
   - Repository : `https://github.com/adamdiaby05-prog/DONS.git`
   - Branch : `master`

#### 2. Configuration de la base de données

**Option A : Base de données MySQL (Recommandée)**
```yaml
# Variables d'environnement à configurer dans Dokploy
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_DATABASE=dons_db
MYSQL_USER=dons_user
MYSQL_PASSWORD=your_secure_password
DB_CONNECTION=mysql
DB_HOST=mysql-db
DB_PORT=3306
```

**Option B : Base de données SQLite (Simple)**
```yaml
# Variables d'environnement
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/backend/database/database.sqlite
```

#### 3. Variables d'environnement requises

```yaml
# Application
APP_NAME=DONS
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-domaine.com

# Base de données
DB_CONNECTION=mysql
DB_HOST=mysql-db
DB_PORT=3306
DB_DATABASE=dons_db
DB_USERNAME=dons_user
DB_PASSWORD=your_secure_password

# Sécurité
APP_KEY=base64:your-generated-app-key

# Cache et Sessions
CACHE_DRIVER=file
SESSION_DRIVER=file
```

#### 4. Configuration Docker

Le projet inclut :
- `Dockerfile` : Configuration pour PHP 8.2 + Apache
- `docker-compose.yml` : Pour le développement local
- `dokploy.yml` : Configuration optimisée pour Dokploy

#### 5. Déploiement

1. **Push du code** : Assurez-vous que tous les fichiers sont poussés vers GitHub
2. **Déploiement automatique** : Dokploy détectera les changements et redéploiera
3. **Vérification** : Vérifiez que l'application est accessible

### 🔧 Configuration avancée

#### Base de données MySQL
```sql
-- Créer la base de données
CREATE DATABASE dons_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur
CREATE USER 'dons_user'@'%' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON dons_db.* TO 'dons_user'@'%';
FLUSH PRIVILEGES;
```

#### Migrations Laravel
```bash
# Exécuter les migrations (dans le conteneur)
php artisan migrate --force

# Créer les tables
php artisan migrate:fresh --seed
```

### 📁 Structure du projet

```
DONS/
├── backend/                 # API Laravel
│   ├── app/                # Logique métier
│   ├── database/           # Migrations et seeders
│   ├── config/             # Configuration
│   └── routes/             # Routes API
├── frontend/               # Application Flutter Web
├── bpay_sdk/              # SDK Barapay
├── Dockerfile             # Configuration Docker
├── docker-compose.yml     # Développement local
└── dokploy.yml           # Configuration Dokploy
```

### 🚨 Dépannage

#### Problèmes courants

1. **Erreur de base de données** :
   - Vérifiez les variables d'environnement
   - Assurez-vous que MySQL est démarré
   - Vérifiez les permissions

2. **Erreur 500** :
   - Vérifiez les logs dans Dokploy
   - Vérifiez la configuration Apache
   - Vérifiez les permissions des fichiers

3. **Problème de CORS** :
   - Configurez les headers CORS dans Laravel
   - Vérifiez la configuration du frontend

#### Logs utiles
```bash
# Logs de l'application
docker logs dons-app

# Logs de la base de données
docker logs mysql-db

# Vérifier les services
docker ps
```

### 🔐 Sécurité

1. **Changez tous les mots de passe par défaut**
2. **Utilisez HTTPS en production**
3. **Configurez un firewall**
4. **Sauvegardez régulièrement la base de données**

### 📞 Support

En cas de problème :
1. Vérifiez les logs dans Dokploy
2. Consultez la documentation Laravel
3. Vérifiez la configuration Docker
