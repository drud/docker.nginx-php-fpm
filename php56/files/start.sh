#!/bin/bash

# Disable Strict Host checking for non interactive git clones


# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
 echo php_flag[display_errors] = off >> /etc/php5/php-fpm.conf
else
 echo php_flag[display_errors] = on >> /etc/php5/php-fpm.conf
fi

# Very dirty hack to replace variables in code with ENVIRONMENT values
if [[ "$TEMPLATE_NGINX_HTML" == "1" ]] ; then
  for i in $(env)
  do
    variable=$(echo "$i" | cut -d'=' -f1)
    value=$(echo "$i" | cut -d'=' -f2)
    if [[ "$variable" != '%s' ]] ; then
      replace='\$\$_'${variable}'_\$\$'
      find /var/www/html -type f -exec sed -i -e 's/'${replace}'/'${value}'/g' {} \;
    fi
  done
fi

if [[ -v GIT_SYNC_REPO ]]; then
  echo "cloning repository"
  export GIT_SYNC_ONE_TIME="true"
  /usr/bin/git-sync
  status=$?
  if [[ $status != 0 ]]; then
    echo "Could not perform git-sync. Exiting."
    exit $status
  fi
fi

# Files mounted to /var/www/html may be owned by a random (host) user, often
# uid 1000, but make sure that nginx can access them in the least intrusive way.
chgrp -R nginx /var/www/html

# if a drud.yaml exists try to run its pre-start task set
if [ -f /var/www/html/drud.yaml ]; then
    if grep -q "pre-start" /var/www/html/drud.yaml; then
        echo "running pre-start hook"
        dcfg run pre-start --config /var/www/html/drud.yaml
    fi
fi

# Start supervisord and services
if [[ "$DEPLOY_NAME" == "local" ]] ; then
    echo "starting local services"
    cp /etc/supervisord-local.conf /etc/supervisord.conf
else
    echo "starting remote services"
    cp /etc/supervisord-remote.conf /etc/supervisord.conf
fi
/usr/bin/supervisord -c /etc/supervisord.conf

echo 'Server started'
tail -f /var/log/nginx/error.log
