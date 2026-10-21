#!/bin/bash

set -e

while ! mariadb -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE &>/dev/null; do
    sleep 3
done

if [ -f ./wp-config.php ] ; then
    echo "WordPress is already installed."
else
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    echo "Installing WordPress and creating Admin..."
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="My Inception Blog" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    echo "Creating standard user..."
    wp user create \
        ${WP_USER} \
        ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

wp config set WP_REDIS_HOST 'redis' --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp plugin install redis-cache --allow-root
wp plugin activate redis-cache --allow-root
wp redis enable --allow-root

exec /usr/sbin/php-fpm8.2 -F
