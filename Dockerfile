FROM debian:stretch
LABEL maintainer="Grzegorz Olszewski <grzegorz@olszewski.in>"

RUN apt-get update; \
    \
    apt-get install -y --no-install-recommends\
    apache2 \
    wget \
    curl \
    ca-certificates \
    unzip \
    php7.0 \
    php7.0-cli \
    libapache2-mod-php7.0 \
    php7.0-bcmath \
    php7.0-bz2  \
    php7.0-curl \
    php7.0-gd \
    php7.0-intl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-sqlite3 \
    php7.0-pgsql \
    php7.0-xml \
    php7.0-zip; \
    apt-get clean; \
    php -i | grep 'Scan this directory for additional'; \
    a2enmod rewrite php7.0; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archive/*.deb;

# PHP settings
RUN set -ex; \
    \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /etc/php/7.0/cli/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly = 1'; \
        echo 'session.use_strict_mode = 1'; \
    } > /etc/php/7.0/cli/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen = On'; \
        echo 'max_execution_time = 6000'; \
        echo 'memory_limit = 512M'; \
    } > /etc/php/7.0/cli/conf.d/susi-others.ini

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

# Download zip and extract
RUN curl -fsSL -o susi-monitor.zip $URL; \
    rm -f /var/www/html/index.html; \
    unzip -q susi-monitor.zip -d /var/www/html; \
    mkdir -p /var/www/html/application/cache; \
    chown -R www-data:www-data /var/www/html; \
    rm -rf /var/www/html/composer.json;

WORKDIR /var/www/html/

# Copy config
COPY susi-config.php /var/www/html/application/config/susi-config.php

# Copy DB config
COPY database.php /etc/susi-monitor/application/config/database.php

COPY docker-entrypoint.sh /sbin/docker-entrypoint.sh
RUN chmod 775 /sbin/docker-entrypoint.sh && chmod 777 -R /var/www/html/application/database

EXPOSE 80 443
ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]
CMD ["/usr/sbin/apache2 -D FOREGROUND"]