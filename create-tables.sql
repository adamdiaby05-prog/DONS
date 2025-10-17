-- Script SQL pour créer toutes les tables de la base de données DONS
-- Base de données PostgreSQL

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

-- Insérer des données de test
INSERT INTO users (name, email, password, is_admin, created_at, updated_at) VALUES
('Admin DONS', 'admin@dons.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', true, NOW(), NOW()),
('John Doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', false, NOW(), NOW()),
('Jane Smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', false, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

INSERT INTO groups (name, description, target_amount, current_amount, status, created_by, created_at, updated_at) VALUES
('Groupe Test 1', 'Description du groupe test 1', 100000.00, 25000.00, 'active', 1, NOW(), NOW()),
('Groupe Test 2', 'Description du groupe test 2', 50000.00, 15000.00, 'active', 1, NOW(), NOW())
ON CONFLICT DO NOTHING;

INSERT INTO group_members (group_id, user_id, role, joined_at) VALUES
(1, 1, 'admin', NOW()),
(1, 2, 'member', NOW()),
(1, 3, 'member', NOW()),
(2, 1, 'admin', NOW()),
(2, 2, 'member', NOW())
ON CONFLICT (group_id, user_id) DO NOTHING;

INSERT INTO contributions (group_id, user_id, amount, status, payment_method, contributed_at, created_at, updated_at) VALUES
(1, 2, 10000.00, 'completed', 'barapay', NOW(), NOW(), NOW()),
(1, 3, 15000.00, 'completed', 'barapay', NOW(), NOW(), NOW()),
(2, 2, 5000.00, 'pending', 'barapay', NOW(), NOW(), NOW())
ON CONFLICT DO NOTHING;

INSERT INTO notifications (user_id, type, title, message, created_at) VALUES
(1, 'info', 'Bienvenue', 'Bienvenue dans DONS !', NOW()),
(2, 'success', 'Contribution réussie', 'Votre contribution a été enregistrée avec succès', NOW()),
(3, 'info', 'Nouveau groupe', 'Vous avez été ajouté à un nouveau groupe', NOW())
ON CONFLICT DO NOTHING;

-- Créer des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_groups_status ON groups(status);
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_contributions_group_id ON contributions(group_id);
CREATE INDEX IF NOT EXISTS idx_contributions_user_id ON contributions(user_id);
CREATE INDEX IF NOT EXISTS idx_contributions_status ON contributions(status);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at);

-- Afficher les tables créées
SELECT 'Tables créées avec succès !' as message;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
