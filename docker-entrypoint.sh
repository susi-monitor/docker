#!/bin/bash
source /etc/apache2/envvars

user="${APACHE_RUN_USER:-www-data}"
group="${APACHE_RUN_GROUP:-www-data}"

echo "PHP version is now hidden."
echo -e 'expose_php = Off\n' >/etc/php/7.0/cli/conf.d/susi-hide-php-version.ini
exec /usr/sbin/apache2 -D FOREGROUND