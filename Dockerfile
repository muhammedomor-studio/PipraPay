
FROM php:8.2-apache

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libonig-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libicu-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install -j"$(nproc)" \
    mysqli \
    pdo_mysql \
    curl \
    mbstring \
    zip \
    gd \
    intl \
    bcmath

# Enable Apache rewrite module
RUN a2enmod rewrite

# Configure Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -ri \
    's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

# Configure Apache port for Render
RUN sed -i 's/Listen 80/Listen 10000/' \
    /etc/apache2/ports.conf \
    && sed -i 's/:80>/:10000>/' \
    /etc/apache2/sites-available/000-default.conf

# Set application directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Expose Render web service port
EXPOSE 10000

# Start Apache
CMD ["apache2-foreground"]