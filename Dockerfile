FROM debian:stretch
LABEL maintainer="Grzegorz Olszewski <grzegorz@olszewski.in>"

ENV APACHE_CONF_DIR=/etc/apache2 \
    PHP_CONF_DIR=/etc/php/7.0 \
    PHP_DATA_DIR=/var/lib/php

#ORACLE Client
RUN mkdir /opt/oracle \
    && cd /opt/oracle

ADD oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip /opt/oracle
ADD oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle
ADD oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /opt/oracle

ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_12_2/client64/lib/
ENV ORACLE_HOME instantclient,/opt/oracle/instantclient_12_2/client64/lib/

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
    unzip /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /opt/oracle \
        && unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle \
        && ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.2 /opt/oracle/instantclient_12_2/libclntsh.so \
        && ln -s /opt/oracle/instantclient_12_2/libclntshcore.so.12.2 /opt/oracle/instantclient_12_2/libclntshcore.so \
        && ln -s /opt/oracle/instantclient_12_2/libocci.so.12.2 /opt/oracle/instantclient_12_2/libocci.so \
        && rm -rf /opt/oracle/*.zip; \
    echo 'instantclient,/opt/oracle/instantclient_12_2/client64/lib' | pecl install -f oci8-2.0.8; \
    echo "extension=oci8.so" > /etc/php7.0/apache2/conf.d/30-oci8.ini; \
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
    mkdir /var/www/app; \
    chown -R www-data:www-data /var/www/app; \
    rm -f /var/www/html/index.html; \
    unzip -q susi-monitor.zip -d /var/www/app; \
    mkdir -p /var/www/app/application/cache; \
    rm -rf /var/www/app/composer.json; \
    # Forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/apache2/access.log; \
    ln -sf /dev/stderr /var/log/apache2/error.log; \
    chown -Rf www-data:www-data ${PHP_DATA_DIR}; \
    rm ${APACHE_CONF_DIR}/sites-enabled/000-default.conf ${APACHE_CONF_DIR}/sites-available/000-default.conf;

# Copy config
COPY app.conf ${APACHE_CONF_DIR}/sites-enabled/app.conf
COPY susi-config.php /var/www/app/application/config/susi-config.php

# Copy DB config
COPY database.php /var/www/app/application/config/database.php

COPY docker-entrypoint.sh /sbin/docker-entrypoint.sh
RUN chmod 775 /sbin/docker-entrypoint.sh

# Work in app directory
WORKDIR /var/www/app/

EXPOSE 80 443
ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]
CMD ["/usr/sbin/apache2 -D FOREGROUND"]