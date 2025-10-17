<?php
/**
 * Script d'initialisation de la base de données DONS
 * Crée toutes les tables et insère les données de test
 */

// Configuration de la base de données
$host = $_ENV['DB_HOST'] ?? 'dons-database-ysb0io';
$port = $_ENV['DB_PORT'] ?? '5432';
$database = $_ENV['DB_DATABASE'] ?? 'Dons';
$username = $_ENV['DB_USERNAME'] ?? 'postgres';
$password = $_ENV['DB_PASSWORD'] ?? '9vx4rsve50bkmekz';

echo "🚀 Initialisation de la base de données DONS...\n";
echo "Host: $host\n";
echo "Database: $database\n";
echo "User: $username\n\n";

try {
    // Connexion à PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ Connexion réussie à PostgreSQL !\n\n";
    
    // 1. Créer la table users
    echo "📊 Création de la table users...\n";
    $pdo->exec("
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
        )
    ");
    echo "✅ Table users créée\n";
    
    // 2. Créer la table groups
    echo "📊 Création de la table groups...\n";
    $pdo->exec("
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
        )
    ");
    echo "✅ Table groups créée\n";
    
    // 3. Créer la table group_members
    echo "📊 Création de la table group_members...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS group_members (
            id SERIAL PRIMARY KEY,
            group_id INTEGER REFERENCES groups(id) ON DELETE CASCADE,
            user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
            role VARCHAR(50) DEFAULT 'member',
            joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(group_id, user_id)
        )
    ");
    echo "✅ Table group_members créée\n";
    
    // 4. Créer la table contributions
    echo "📊 Création de la table contributions...\n";
    $pdo->exec("
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
        )
    ");
    echo "✅ Table contributions créée\n";
    
    // 5. Créer la table payments
    echo "📊 Création de la table payments...\n";
    $pdo->exec("
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
        )
    ");
    echo "✅ Table payments créée\n";
    
    // 6. Créer la table notifications
    echo "📊 Création de la table notifications...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS notifications (
            id SERIAL PRIMARY KEY,
            user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
            type VARCHAR(50) NOT NULL,
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            data JSONB,
            read_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");
    echo "✅ Table notifications créée\n";
    
    // 7. Créer la table cache
    echo "📊 Création de la table cache...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS cache (
            key VARCHAR(255) PRIMARY KEY,
            value TEXT NOT NULL,
            expiration INTEGER NOT NULL
        )
    ");
    echo "✅ Table cache créée\n";
    
    // 8. Créer la table jobs
    echo "📊 Création de la table jobs...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS jobs (
            id SERIAL PRIMARY KEY,
            queue VARCHAR(255) NOT NULL,
            payload TEXT NOT NULL,
            attempts INTEGER DEFAULT 0,
            reserved_at INTEGER NULL,
            available_at INTEGER NOT NULL,
            created_at INTEGER NOT NULL
        )
    ");
    echo "✅ Table jobs créée\n";
    
    // 9. Créer la table migrations
    echo "📊 Création de la table migrations...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS migrations (
            id SERIAL PRIMARY KEY,
            migration VARCHAR(255) NOT NULL,
            batch INTEGER NOT NULL
        )
    ");
    echo "✅ Table migrations créée\n";
    
    // 10. Créer la table personal_access_tokens
    echo "📊 Création de la table personal_access_tokens...\n";
    $pdo->exec("
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
        )
    ");
    echo "✅ Table personal_access_tokens créée\n";
    
    echo "\n🎉 Toutes les tables ont été créées avec succès !\n";
    
    // Insérer des données de test
    echo "\n📝 Insertion des données de test...\n";
    
    // Insérer des utilisateurs de test
    $pdo->exec("
        INSERT INTO users (name, email, password, is_admin, created_at, updated_at) VALUES
        ('Admin DONS', 'admin@dons.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', true, NOW(), NOW()),
        ('John Doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', false, NOW(), NOW()),
        ('Jane Smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', false, NOW(), NOW())
        ON CONFLICT (email) DO NOTHING
    ");
    echo "✅ Utilisateurs de test insérés\n";
    
    // Insérer des groupes de test
    $pdo->exec("
        INSERT INTO groups (name, description, target_amount, current_amount, status, created_by, created_at, updated_at) VALUES
        ('Groupe Test 1', 'Description du groupe test 1', 100000.00, 25000.00, 'active', 1, NOW(), NOW()),
        ('Groupe Test 2', 'Description du groupe test 2', 50000.00, 15000.00, 'active', 1, NOW(), NOW())
        ON CONFLICT DO NOTHING
    ");
    echo "✅ Groupes de test insérés\n";
    
    // Insérer des membres de groupe
    $pdo->exec("
        INSERT INTO group_members (group_id, user_id, role, joined_at) VALUES
        (1, 1, 'admin', NOW()),
        (1, 2, 'member', NOW()),
        (1, 3, 'member', NOW()),
        (2, 1, 'admin', NOW()),
        (2, 2, 'member', NOW())
        ON CONFLICT (group_id, user_id) DO NOTHING
    ");
    echo "✅ Membres de groupe insérés\n";
    
    // Insérer des contributions de test
    $pdo->exec("
        INSERT INTO contributions (group_id, user_id, amount, status, payment_method, contributed_at, created_at, updated_at) VALUES
        (1, 2, 10000.00, 'completed', 'barapay', NOW(), NOW(), NOW()),
        (1, 3, 15000.00, 'completed', 'barapay', NOW(), NOW(), NOW()),
        (2, 2, 5000.00, 'pending', 'barapay', NOW(), NOW(), NOW())
        ON CONFLICT DO NOTHING
    ");
    echo "✅ Contributions de test insérées\n";
    
    // Insérer des notifications de test
    $pdo->exec("
        INSERT INTO notifications (user_id, type, title, message, created_at) VALUES
        (1, 'info', 'Bienvenue', 'Bienvenue dans DONS !', NOW()),
        (2, 'success', 'Contribution réussie', 'Votre contribution a été enregistrée avec succès', NOW()),
        (3, 'info', 'Nouveau groupe', 'Vous avez été ajouté à un nouveau groupe', NOW())
        ON CONFLICT DO NOTHING
    ");
    echo "✅ Notifications de test insérées\n";
    
    echo "\n🎉 Base de données DONS initialisée avec succès !\n";
    echo "📊 Tables créées : 10\n";
    echo "👥 Utilisateurs : 3\n";
    echo "👥 Groupes : 2\n";
    echo "💰 Contributions : 3\n";
    echo "🔔 Notifications : 3\n";
    
    // Vérifier les tables créées
    $stmt = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name");
    $tables = $stmt->fetchAll();
    
    echo "\n📋 Tables disponibles :\n";
    foreach ($tables as $table) {
        echo "  ✅ " . $table['table_name'] . "\n";
    }
    
    echo "\n🚀 La base de données DONS est maintenant prête à être utilisée !\n";
    
} catch (PDOException $e) {
    echo "❌ Erreur lors de l'initialisation : " . $e->getMessage() . "\n";
    echo "🔧 Vérifiez :\n";
    echo "  - Que PostgreSQL est démarré\n";
    echo "  - Les variables d'environnement DB_*\n";
    echo "  - Les permissions de l'utilisateur\n";
    exit(1);
}
?>
