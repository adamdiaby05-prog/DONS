<?php
/**
 * Script de test des tables de la base de données DONS
 * Vérifie que toutes les tables sont créées et contiennent des données
 */

// Configuration de la base de données
$host = $_ENV['DB_HOST'] ?? 'dons-database-ysb0io';
$port = $_ENV['DB_PORT'] ?? '5432';
$database = $_ENV['DB_DATABASE'] ?? 'Dons';
$username = $_ENV['DB_USERNAME'] ?? 'postgres';
$password = $_ENV['DB_PASSWORD'] ?? '9vx4rsve50bkmekz';

echo "🔍 Test des tables de la base de données DONS...\n";
echo "Host: $host\n";
echo "Database: $database\n\n";

try {
    // Connexion à PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ Connexion réussie à PostgreSQL !\n\n";
    
    // Liste des tables attendues
    $expectedTables = [
        'users', 'groups', 'group_members', 'contributions', 
        'payments', 'notifications', 'cache', 'jobs', 
        'migrations', 'personal_access_tokens'
    ];
    
    // Vérifier les tables existantes
    $stmt = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name");
    $existingTables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "📊 Tables trouvées :\n";
    foreach ($existingTables as $table) {
        echo "  ✅ $table\n";
    }
    
    echo "\n🔍 Vérification des tables attendues :\n";
    $missingTables = [];
    foreach ($expectedTables as $expectedTable) {
        if (in_array($expectedTable, $existingTables)) {
            echo "  ✅ $expectedTable - Présente\n";
        } else {
            echo "  ❌ $expectedTable - Manquante\n";
            $missingTables[] = $expectedTable;
        }
    }
    
    if (!empty($missingTables)) {
        echo "\n❌ Tables manquantes : " . implode(', ', $missingTables) . "\n";
        echo "🔧 Exécutez le script init-database.php pour créer les tables manquantes\n";
    } else {
        echo "\n✅ Toutes les tables attendues sont présentes !\n";
    }
    
    // Vérifier les données dans chaque table
    echo "\n📊 Vérification des données :\n";
    
    // Test de la table users
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $userCount = $stmt->fetch()['count'];
    echo "  👥 Utilisateurs : $userCount\n";
    
    // Test de la table groups
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM groups");
    $groupCount = $stmt->fetch()['count'];
    echo "  👥 Groupes : $groupCount\n";
    
    // Test de la table group_members
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM group_members");
    $memberCount = $stmt->fetch()['count'];
    echo "  👥 Membres de groupe : $memberCount\n";
    
    // Test de la table contributions
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM contributions");
    $contributionCount = $stmt->fetch()['count'];
    echo "  💰 Contributions : $contributionCount\n";
    
    // Test de la table notifications
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM notifications");
    $notificationCount = $stmt->fetch()['count'];
    echo "  🔔 Notifications : $notificationCount\n";
    
    // Test des relations
    echo "\n🔗 Test des relations :\n";
    
    // Test relation users -> groups
    $stmt = $pdo->query("
        SELECT u.name, g.name as group_name 
        FROM users u 
        JOIN group_members gm ON u.id = gm.user_id 
        JOIN groups g ON gm.group_id = g.id 
        LIMIT 5
    ");
    $relations = $stmt->fetchAll();
    echo "  👥 Relations utilisateurs-groupes : " . count($relations) . " trouvées\n";
    
    // Test relation groups -> contributions
    $stmt = $pdo->query("
        SELECT g.name, COUNT(c.id) as contribution_count 
        FROM groups g 
        LEFT JOIN contributions c ON g.id = c.group_id 
        GROUP BY g.id, g.name
    ");
    $groupContributions = $stmt->fetchAll();
    echo "  💰 Relations groupes-contributions : " . count($groupContributions) . " trouvées\n";
    
    // Test de performance
    echo "\n⚡ Test de performance :\n";
    $start = microtime(true);
    $stmt = $pdo->query("SELECT COUNT(*) FROM users WHERE is_admin = true");
    $adminCount = $stmt->fetch()['count'];
    $end = microtime(true);
    $time = round(($end - $start) * 1000, 2);
    echo "  ⏱️ Requête admin : {$time}ms (Admins trouvés : $adminCount)\n";
    
    // Test des index
    echo "\n📈 Vérification des index :\n";
    $stmt = $pdo->query("
        SELECT indexname, tablename 
        FROM pg_indexes 
        WHERE schemaname = 'public' 
        ORDER BY tablename, indexname
    ");
    $indexes = $stmt->fetchAll();
    echo "  📊 Index créés : " . count($indexes) . "\n";
    
    // Résumé final
    echo "\n🎉 Résumé du test :\n";
    echo "  📊 Tables : " . count($existingTables) . "/" . count($expectedTables) . "\n";
    echo "  👥 Utilisateurs : $userCount\n";
    echo "  👥 Groupes : $groupCount\n";
    echo "  💰 Contributions : $contributionCount\n";
    echo "  🔔 Notifications : $notificationCount\n";
    echo "  📈 Index : " . count($indexes) . "\n";
    
    if (empty($missingTables) && $userCount > 0 && $groupCount > 0) {
        echo "\n✅ Base de données DONS configurée correctement !\n";
        echo "🚀 Prête pour le déploiement de l'application !\n";
    } else {
        echo "\n⚠️ Base de données incomplète\n";
        echo "🔧 Exécutez init-database.php pour corriger les problèmes\n";
    }
    
} catch (PDOException $e) {
    echo "❌ Erreur lors du test : " . $e->getMessage() . "\n";
    echo "🔧 Vérifiez :\n";
    echo "  - Que PostgreSQL est démarré\n";
    echo "  - Les variables d'environnement DB_*\n";
    echo "  - Les permissions de l'utilisateur\n";
    exit(1);
}
?>
