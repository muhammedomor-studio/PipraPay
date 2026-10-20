
FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
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

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

RUN docker-php-ext-install -j"$(nproc)" \
    mysqli \
    pdo_mysql \
    curl \
    mbstring \
    zip \
    gd \
    intl \
    bcmath

# Install Imagick PHP extension
RUN pecl install imagick \
    && docker-php-ext-enable imagick

RUN a2enmod rewrite

ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -ri \
    's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

RUN sed -i 's/Listen 80/Listen 10000/' \
    /etc/apache2/ports.conf \
    && sed -i 's/:80>/:10000>/' \
    /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

COPY . /var/www/html/

EXPOSE 10000

CMD ["apache2-foreground"]