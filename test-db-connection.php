<?php
/**
 * Script de test de connexion à la base de données PostgreSQL
 * À exécuter dans le conteneur pour vérifier la connexion
 */

// Configuration de la base de données
$host = $_ENV['DB_HOST'] ?? 'dons-database';
$port = $_ENV['DB_PORT'] ?? '5432';
$database = $_ENV['DB_DATABASE'] ?? 'Dons';
$username = $_ENV['DB_USERNAME'] ?? 'postgres';
$password = $_ENV['DB_PASSWORD'] ?? '';

echo "🔍 Test de connexion à PostgreSQL...\n";
echo "Host: $host\n";
echo "Port: $port\n";
echo "Database: $database\n";
echo "Username: $username\n";
echo "Password: " . (empty($password) ? '❌ Non défini' : '✅ Défini') . "\n\n";

try {
    // Connexion à PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ Connexion réussie à PostgreSQL !\n";
    
    // Test des tables
    $stmt = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
    $tables = $stmt->fetchAll();
    
    echo "📊 Tables disponibles :\n";
    foreach ($tables as $table) {
        echo "  - " . $table['table_name'] . "\n";
    }
    
    // Test de création d'une table de test
    $pdo->exec("CREATE TABLE IF NOT EXISTS test_connection (id SERIAL PRIMARY KEY, message TEXT, created_at TIMESTAMP DEFAULT NOW())");
    echo "✅ Table de test créée avec succès\n";
    
    // Test d'insertion
    $stmt = $pdo->prepare("INSERT INTO test_connection (message) VALUES (?)");
    $stmt->execute(['Test de connexion réussi']);
    echo "✅ Insertion de test réussie\n";
    
    // Test de sélection
    $stmt = $pdo->query("SELECT * FROM test_connection ORDER BY created_at DESC LIMIT 1");
    $result = $stmt->fetch();
    echo "✅ Sélection réussie : " . $result['message'] . "\n";
    
    // Nettoyage
    $pdo->exec("DROP TABLE test_connection");
    echo "✅ Table de test supprimée\n";
    
    echo "\n🎉 Tous les tests de connexion PostgreSQL sont réussis !\n";
    
} catch (PDOException $e) {
    echo "❌ Erreur de connexion : " . $e->getMessage() . "\n";
    echo "🔧 Vérifiez :\n";
    echo "  - Que PostgreSQL est démarré\n";
    echo "  - Les variables d'environnement DB_*\n";
    echo "  - Les permissions de l'utilisateur\n";
    exit(1);
}
?>
