# Dockerfile pour l'API DONS Backend
FROM php:8.2-cli

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers de l'application
COPY . .

# Installer les dépendances PHP
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader; fi

# Exposer le port 8000
EXPOSE 8000

# Script de démarrage
CMD ["php", "-S", "0.0.0.0:8000", "-t", "."]
