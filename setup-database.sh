#!/bin/bash

# Script de configuration de la base de données DONS
echo "🚀 Configuration de la base de données DONS..."

# Variables d'environnement
DB_HOST=${DB_HOST:-"dons-database-ysb0io"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"Dons"}
DB_USER=${DB_USER:-"postgres"}
DB_PASSWORD=${DB_PASSWORD:-"9vx4rsve50bkmekz"}

echo "📊 Connexion à la base de données..."
echo "Host: $DB_HOST"
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; do
    echo "PostgreSQL n'est pas encore prêt..."
    sleep 2
done

echo "✅ PostgreSQL est prêt !"

# Exécuter le script SQL
echo "📝 Exécution du script SQL..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f create-tables.sql

if [ $? -eq 0 ]; then
    echo "🎉 Base de données DONS configurée avec succès !"
    echo "📊 Tables créées :"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
else
    echo "❌ Erreur lors de la configuration de la base de données"
    exit 1
fi
