# PHP 8.4 CLI Alpine Base com Swoole + Redis + Composer + libs runtime
FROM php:8.4-cli-alpine AS base

FROM base AS builder 
RUN apk add --no-cache \
        $PHPIZE_DEPS \
        autoconf \
        g++ \
        make \
        linux-headers \
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
        pdo_pgsql pdo bcmath mbstring xml gd opcache pcntl \
    && pecl install swoole-6.1.6 redis \
    && docker-php-ext-enable swoole redis


FROM base AS runtime
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=composer:2.9.5 /usr/bin/composer /usr/bin/composer
RUN apk add --no-cache \
        postgresql-libs \
        libpng \
        libjpeg-turbo \
        freetype \
        curl \
        libxml2 \
        libstdc++ \
        && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN addgroup -g 1000 -S appuser \
    && adduser -u 1000 -S appuser -G appuser 

RUN echo "opcache.enable=\${OPCACHE_ENABLED}" > /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.enable_cli=\${OPCACHE_ENABLED}" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=\${OPCACHE_MEMORY}" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=\${OPCACHE_MAX_FILES}" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=\${OPCACHE_VALIDATE_TIMESTAMPS}" >> /usr/local/etc/php/conf.d/opcache.ini