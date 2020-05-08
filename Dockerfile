FROM php:7.4-apache

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
        wget \
        curl \
        unzip \
    ; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j "$(nproc)" \
        bz2 \
        gd \
        curl \
        pdo \
        pgsql \
        sqlite3 \
        mysqli \
        opcache \
        zip \
    ; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# PHP settings
RUN set -ex; \
    \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly = 1'; \
        echo 'session.use_strict_mode = 1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen = On'; \
        echo 'max_execution_time = 6000'; \
        echo 'memory_limit = 512M'; \
    } > $PHP_INI_DIR/conf.d/phpmyadmin-misc.ini

# Generate download URL
ENV VERSION 1.4.3
ENV URL https://github.com/susi-monitor/susi-monitor/releases/download/${VERSION}/susi_monitor_${VERSION}_bundle.zip
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Grzegorz Olszewski <grzegorz@olszewski.in>" \
    org.opencontainers.image.title="Official SuSi Monitor Docker image" \
    org.opencontainers.image.description="SuSi is a simple yet powerful uptime and response time monitor." \
    org.opencontainers.image.authors="Grzegorz Olszewski <grzegorz@olszewski.in>" \
    org.opencontainers.image.vendor="susimonitor" \
    org.opencontainers.image.documentation="https://github.com/susi-motnitor/docker#readme" \
    org.opencontainers.image.url="https://github.com/susi-motnitor/docker#readme" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.source="https://github.com/susi-monitor/docker.git" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.created="${BUILD_DATE}"

# Download tarball, verify it using gpg and extract
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        dirmngr \
    ; \
    \
    curl -fsSL -o susi-monitor.zip $URL; \
    unzip susi-monitor.zip -d /var/www/html; \
    mkdir -p /var/www/html/application/cache; \
    chown -R www-data:www-data /var/www/html; \
    rm -rf /var/www/html/composer.json; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Copy config
COPY susi-config.php /etc/susi-monitor/application/config/susi-config.php

# Copy DB config
COPY database.php /etc/susi-monitor/application/config/database.php

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["apache2-foreground"]