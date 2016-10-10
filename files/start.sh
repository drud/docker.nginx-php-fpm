#!/bin/bash

# Disable Strict Host checking for non interactive git clones

mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

if [ ! -z "$SSH_KEY" ]; then
 echo $SSH_KEY > /root/.ssh/id_rsa.base64
 base64 -d /root/.ssh/id_rsa.base64 > /root/.ssh/id_rsa
 chmod 600 /root/.ssh/id_rsa
fi

# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

# Pull down code from git for our site!
if [ ! -z "$GIT_REPO" ]; then
  rm -Rf /var/www/html
  mkdir /var/www/html
  if [ ! -z "$GIT_BRANCH" ]; then
    git clone -b $GIT_BRANCH $GIT_REPO /var/www/html/
  else
    git clone $GIT_REPO /var/www/html/
  fi
  chown -Rf nginx.nginx /var/www/html
fi

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

# Ensure code and files dir is owned by nginx user and nginx can write to files volume mount.
cp -r /src/docroot/*  /var/www/html/docroot/
chown -Rf nginx.nginx /var/www/html/docroot
#chown -Rf nginx.nginx /files
#chmod 755 /files

# Start supervisord and services
/usr/bin/supervisord -c /etc/supervisord.conf
echo 'Server started'
tail -f /var/log/nginx/error.log