#!/bin/bash
source /etc/apache2/envvars

user="${APACHE_RUN_USER:-www-data}"
group="${APACHE_RUN_GROUP:-www-data}"

echo "PHP version is now hidden."
echo -e 'expose_php = Off\n' >/etc/php/7.0/cli/conf.d/susi-hide-php-version.ini

FILE=/data/data.db
if [ -f "$FILE" ]; then
    echo "$FILE exists - will not copy the DB as it is already in place."
else
    echo "$FILE does not exist - creating new SQLite DB there."
    cp /var/www/app/application/database/data.db /data/data.db
    chown -R www-data:www-data /data/
fi


exec /usr/sbin/apache2 -D FOREGROUND