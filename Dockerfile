# PHP 8.4 CLI Alpine Base com Swoole + Redis + Composer + libs runtime
FROM php:8.4-cli-alpine

# -----------------------------
# Dependências de build
# -----------------------------
RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        linux-headers \
        autoconf \
        postgresql-dev \
        curl-dev \
        libxml2-dev \
        icu-dev \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        oniguruma-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_pgsql \
        bcmath \
        mbstring \
        xml \
        curl \
        ctype \
        fileinfo \
        gd \
        opcache
        
RUN docker-php-ext-install pcntl
RUN pecl install swoole-6.1.6 redis \
    && docker-php-ext-enable swoole redis \
    && apk del .build-deps \
    && rm -rf /tmp/pear /var/cache/apk/*

# -----------------------------
# Bibliotecas runtime
# -----------------------------
RUN apk add --no-cache \
        postgresql-libs \
        libpng \
        libjpeg-turbo \
        freetype \
        curl \
        libxml2 \
        libstdc++

# -----------------------------
# Composer
# -----------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# -----------------------------
# Usuário não-root
# -----------------------------
RUN addgroup -g 1000 -S appuser \
    && adduser -u 1000 -S appuser -G appuser 

# Arquivo ini do Opcache com placeholders
RUN echo "opcache.enable=${OPCACHE_ENABLE}" > /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.enable_cli=${OPCACHE_ENABLE}" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=${OPCACHE_MEMORY}" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=${OPCACHE_MAX_FILES}" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=${OPCACHE_VALIDATE_TIMESTAMPS}" >> /usr/local/etc/php/conf.d/opcache.ini