#!/bin/bash

# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
 echo php_flag[display_errors] = off >> /etc/php/7.0/fpm/php-fpm.conf
else
 echo php_flag[display_errors] = on >> /etc/php/7.0/fpm/php-fpm.conf
fi

# Files mounted to /var/www/html may be owned by a random (host) user, often
# uid 1000, but make sure that nginx can access them in the least intrusive way.
chgrp -R nginx /var/www/html

/usr/bin/supervisord -c /etc/supervisord.conf

echo 'Server started'
tail -f /var/log/nginx/error.log
