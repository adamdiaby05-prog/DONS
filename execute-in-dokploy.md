# 🚀 Exécution des commandes dans Dokploy

## Méthode 1 : Via l'interface Dokploy

### 1. Accédez à votre base de données
1. Connectez-vous à votre dashboard Dokploy
2. Allez dans votre projet
3. Cliquez sur la base de données `dons-database`

### 2. Ouvrez le terminal de la base de données
1. Cliquez sur l'onglet "Terminal" ou "Console"
2. Vous serez connecté directement à la base de données PostgreSQL

### 3. Exécutez les commandes SQL
```sql
-- Créer les tables
\i /path/to/create-tables.sql

-- Ou exécutez directement les commandes SQL
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Méthode 2 : Via l'application déployée

### 1. Déployez d'abord l'application
1. Créez une nouvelle application sur Dokploy
2. Utilisez le repository GitHub
3. Configurez les variables d'environnement

### 2. Exécutez les migrations Laravel
```bash
# Dans le terminal de l'application
php artisan migrate --force
php artisan db:seed
```

## Méthode 3 : Script d'initialisation automatique

### 1. Ajoutez ce script à votre application
Créez un fichier `init-db.php` dans votre application :

```php
<?php
// Script d'initialisation automatique
require_once 'init-database.php';
?>
```

### 2. Exécutez-le lors du déploiement
Ajoutez cette commande dans votre Dockerfile :
```dockerfile
RUN php init-database.php
```

## Méthode 4 : Via pgAdmin (Interface graphique)

### 1. Installez pgAdmin
1. Dans Dokploy, créez un service pgAdmin
2. Configurez la connexion à votre base de données

### 2. Utilisez l'interface graphique
1. Connectez-vous à pgAdmin
2. Ouvrez l'éditeur SQL
3. Copiez-collez le contenu de `create-tables.sql`
4. Exécutez le script

## Commandes SQL directes

Si vous préférez exécuter les commandes une par une :

```sql
-- 1. Table users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table groups
CREATE TABLE IF NOT EXISTS groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    target_amount DECIMAL(10,2) NOT NULL,
    current_amount DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table group_members
CREATE TABLE IF NOT EXISTS group_members (
    id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

-- 4. Table contributions
CREATE TABLE IF NOT EXISTS contributions (
    id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),
    contributed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Table payments
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    contribution_id INTEGER REFERENCES contributions(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'XOF',
    payment_method VARCHAR(50) NOT NULL,
    payment_reference VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'pending',
    transaction_id VARCHAR(255),
    payment_url TEXT,
    callback_url TEXT,
    success_url TEXT,
    cancel_url TEXT,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Table notifications
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Table cache
CREATE TABLE IF NOT EXISTS cache (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT NOT NULL,
    expiration INTEGER NOT NULL
);

-- 8. Table jobs
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    queue VARCHAR(255) NOT NULL,
    payload TEXT NOT NULL,
    attempts INTEGER DEFAULT 0,
    reserved_at INTEGER NULL,
    available_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL
);

-- 9. Table migrations
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch INTEGER NOT NULL
);

-- 10. Table personal_access_tokens
CREATE TABLE IF NOT EXISTS personal_access_tokens (
    id SERIAL PRIMARY KEY,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    token VARCHAR(64) UNIQUE NOT NULL,
    abilities TEXT,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Vérification

Après avoir créé les tables, vérifiez avec :

```sql
-- Lister toutes les tables
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;

-- Compter les tables
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';
```

## Prochaines étapes

1. Créez les tables avec une des méthodes ci-dessus
2. Déployez votre application DONS
3. Testez la connexion à la base de données
4. Vérifiez que tout fonctionne correctement
