FROM php:8.2-cli

# Install required PHP extensions for MySQL and Laravel
RUN apt-get update && apt-get install -y \
    unzip \
    libpq-dev \
    libonig-dev \
    libzip-dev \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

WORKDIR /var/www/html

COPY . .

# Copy composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Render assigns a dynamic port via $PORT environment variable
EXPOSE 8000

CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
