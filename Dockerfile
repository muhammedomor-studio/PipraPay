
FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

# System libraries required by PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libonig-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libicu-dev \
    libmagickwand-dev \
    unzip \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Configure GD and install PHP extensions
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        mysqli \
        pdo_mysql \
        curl \
        mbstring \
        zip \
        gd \
        intl \
        bcmath

# Install Imagick for image processing
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache to use Render's default HTTP port
RUN sed -ri \
        's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/sites-available/*.conf \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-available/*.conf \
    && sed -i 's/Listen 80/Listen 10000/' \
        /etc/apache2/ports.conf \
    && sed -i 's/:80>/:10000>/' \
        /etc/apache2/sites-available/000-default.conf

ENV APACHE_DOCUMENT_ROOT=/var/www/html

WORKDIR /var/www/html

# Copy the application files
COPY . /var/www/html/

# Allow the installer to create its temporary config
# and allow uploaded media to be written by Apache
RUN chown www-data:www-data /var/www/html \
    && chmod 755 /var/www/html \
    && if [ -d /var/www/html/pp-media ]; then \
        chown -R www-data:www-data /var/www/html/pp-media; \
    fi

EXPOSE 10000

CMD ["apache2-foreground"]
