# 🚀 Guide pour accéder au terminal dans Dokploy

## 📍 Informations de votre base de données

**Nouvelles informations :**
- **Host** : `dons-database-dgzain`
- **Database** : `postgres`
- **User** : `postgres`
- **Port** : `5432`

## 🔍 Comment accéder au terminal dans Dokploy

### Méthode 1 : Via l'onglet "Logs"
1. Dans l'interface que vous avez ouverte, cliquez sur l'onglet **"Logs"**
2. Cherchez un bouton **"Terminal"** ou **"Console"** dans cette section
3. Cliquez dessus pour ouvrir le terminal

### Méthode 2 : Via l'onglet "Advanced"
1. Cliquez sur l'onglet **"Advanced"**
2. Cherchez une section **"Terminal"** ou **"Console"**
3. Cliquez pour ouvrir le terminal

### Méthode 3 : Via l'onglet "General"
1. Dans l'onglet **"General"**
2. Cherchez un bouton **"Terminal"** ou **"Shell"**
3. Cliquez pour accéder au terminal

### Méthode 4 : Via l'onglet "Environment"
1. Dans l'onglet **"Environment"**
2. Cherchez une option **"Terminal"** ou **"Console"**

## 🎯 Une fois dans le terminal, exécutez ces commandes :

### 1. Connectez-vous à PostgreSQL
```bash
psql -U postgres -d postgres
```

### 2. Créez la base de données DONS
```sql
CREATE DATABASE dons;
```

### 3. Connectez-vous à la base DONS
```sql
\c dons
```

### 4. Créez les tables
```sql
-- Table users
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

-- Table groups
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

-- Table group_members
CREATE TABLE IF NOT EXISTS group_members (
    id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

-- Table contributions
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

-- Table payments
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

-- Table notifications
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

-- Table cache
CREATE TABLE IF NOT EXISTS cache (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT NOT NULL,
    expiration INTEGER NOT NULL
);

-- Table jobs
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    queue VARCHAR(255) NOT NULL,
    payload TEXT NOT NULL,
    attempts INTEGER DEFAULT 0,
    reserved_at INTEGER NULL,
    available_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL
);

-- Table migrations
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch INTEGER NOT NULL
);

-- Table personal_access_tokens
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

### 5. Vérifiez les tables créées
```sql
\dt
```

### 6. Insérez des données de test
```sql
-- Insérer des utilisateurs de test
INSERT INTO users (name, email, password, is_admin, created_at, updated_at) VALUES
('Admin DONS', 'admin@dons.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', true, NOW(), NOW()),
('John Doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', false, NOW(), NOW()),
('Jane Smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', false, NOW(), NOW());

-- Insérer des groupes de test
INSERT INTO groups (name, description, target_amount, current_amount, status, created_by, created_at, updated_at) VALUES
('Groupe Test 1', 'Description du groupe test 1', 100000.00, 25000.00, 'active', 1, NOW(), NOW()),
('Groupe Test 2', 'Description du groupe test 2', 50000.00, 15000.00, 'active', 1, NOW(), NOW());

-- Insérer des membres de groupe
INSERT INTO group_members (group_id, user_id, role, joined_at) VALUES
(1, 1, 'admin', NOW()),
(1, 2, 'member', NOW()),
(1, 3, 'member', NOW()),
(2, 1, 'admin', NOW()),
(2, 2, 'member', NOW());

-- Insérer des contributions de test
INSERT INTO contributions (group_id, user_id, amount, status, payment_method, contributed_at, created_at, updated_at) VALUES
(1, 2, 10000.00, 'completed', 'barapay', NOW(), NOW(), NOW()),
(1, 3, 15000.00, 'completed', 'barapay', NOW(), NOW(), NOW()),
(2, 2, 5000.00, 'pending', 'barapay', NOW(), NOW(), NOW());

-- Insérer des notifications de test
INSERT INTO notifications (user_id, type, title, message, created_at) VALUES
(1, 'info', 'Bienvenue', 'Bienvenue dans DONS !', NOW()),
(2, 'success', 'Contribution réussie', 'Votre contribution a été enregistrée avec succès', NOW()),
(3, 'info', 'Nouveau groupe', 'Vous avez été ajouté à un nouveau groupe', NOW());
```

### 7. Vérifiez les données
```sql
-- Lister toutes les tables
\dt

-- Compter les enregistrements
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'groups', COUNT(*) FROM groups
UNION ALL
SELECT 'group_members', COUNT(*) FROM group_members
UNION ALL
SELECT 'contributions', COUNT(*) FROM contributions
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications;
```

## 🎯 Résultat attendu

Vous devriez voir :
- ✅ **10 tables créées**
- ✅ **3 utilisateurs**
- ✅ **2 groupes**
- ✅ **5 membres de groupe**
- ✅ **3 contributions**
- ✅ **3 notifications**

## 🔧 Si vous ne trouvez pas le terminal

Si vous ne trouvez pas d'onglet "Terminal" ou "Console", essayez :
1. **Actualisez la page** (F5)
2. **Cherchez un bouton "Shell"** ou "Command Line"
3. **Regardez dans l'onglet "Advanced"** pour des options de terminal
4. **Vérifiez s'il y a un bouton "Connect"** ou "Open Terminal"

Votre base de données DONS sera maintenant complètement configurée ! 🚀
