#!/bin/bash

# Update full path NGINX_DOCROOT if DOCROOT env is provided
if [ -n "$DOCROOT" ] ; then
    export NGINX_DOCROOT="/var/www/html/$DOCROOT"
fi

# Substitute values of environment variables in nginx configuration
envsubst "$NGINX_SITE_VARS" < /etc/nginx/nginx-site.conf > /etc/nginx/sites-available/site.conf

# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
 echo php_flag[display_errors] = off >> /etc/php/7.0/fpm/php-fpm.conf
else
 echo php_flag[display_errors] = on >> /etc/php/7.0/fpm/php-fpm.conf
fi

# Files mounted to /var/www/html may be owned by a random (host) user, often
# uid 1000, but make sure that nginx can access them in the least intrusive way.
chgrp -R nginx /var/www/html

chown -R nginx:nginx /var/log/nginx

/usr/bin/supervisord -c /etc/supervisord.conf

echo 'Server started'
tail -f /var/log/nginx/error.log
