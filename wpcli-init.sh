#!/bin/sh
set -e
DB_HOST=${DB_HOST:-"localhost"}
DB_USER=${DB_USER:-"wbuser"}
DB_PASS=${DB_PASS:-"wppass"}
DB_NAME=${DB_NAME:-"wpdb"}
WP_URL=${WP_URL:-"localhost"}
WP_ADMIN=${WP_ADMIN:-"admin"}
WP_PASS=${WP_PASS:-"passw0rd"}
WP_EMAIL=${WP_EMAIL:-"admin@local.host"}
WP_TITLE=${WP_TITLE:-"WordPress"}
WP_DESCRIPTION=${WP_DESCRIPTION:-"Just Another WordPress Blog"}
chmod g=u,o= /var/www/html
if [ ! -e /var/www/html/wp-config.php ]; then
    umask 0007
    gosu 1000:0 wp core download --path="/var/www/html" --quiet
    echo "sleep 10"
    sleep 10
    gosu 1000:0 wp config create --path="/var/www/html" --dbhost=$DB_HOST --dbuser=$DB_USER --dbpass=$DB_PASS --dbname=$DB_NAME
    gosu 1000:0 wp core install --path="/var/www/html" --url=$WP_URL --admin_user=$WP_ADMIN --admin_password=$WP_PASS --admin_email=$WP_EMAIL --title=$WP_TITLE --skip-email --skip-plugins
    gosu 1000:0 wp option --path="/var/www/html" update blogdescription "$WP_DESCRIPTION"
    gosu 1000:0 wp rewrite --path="/var/www/html" structure '/%postname%/'
    gosu 1000:0 wp plugin --path="/var/www/html" delete akismet hello
    gosu 1000:0 wp theme --path="/var/www/html" delete twentytwenty twentytwentyone
fi
gosu 1000:0 wp --info
exec gosu 1000:0 tail -f /dev/null