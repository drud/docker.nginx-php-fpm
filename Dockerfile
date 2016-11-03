FROM ubuntu:16.04
MAINTAINER Brad Bowman <brad@drud.com>

ENV php_conf /etc/php/7.0/cli/php.ini
ENV fpm_conf /etc/php/7.0/fpm/php-fpm.conf

RUN apt-get update

RUN apt-get install -y unattended-upgrades apt-listchanges

# Install tools
RUN apt-get install -y \
    python-setuptools \
    python-software-properties \
    software-properties-common \
    language-pack-en-base \
    wget \
    git \
    curl \
    zip \
    vim

# Add repository
RUN PPAPHP7=" ppa:ondrej/php" && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    add-apt-repository $PPAPHP7

RUN apt-get update

# Install libs and dependency's
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
    libcurl4-openssl-dev \
    libmcrypt-dev \
    libxml2-dev \
    libjpeg-dev \
    libjpeg62 \
    libfreetype6-dev \
    libmysqlclient-dev \
    libgmp-dev \
    libpspell-dev \
    libicu-dev \
    librecode-dev \
    snmp

# Install PHP7 and Nginx
RUN apt-get install -y --force-yes \
    php-cgi \
    php-fpm \
    php-cli \
    php7.0-xsl \
    php-common \
    php-json \
    php7.0-opcache \
    php-mysql \
    php-phpdbg \
    php-intl \
    php-gd \
    php-imap \
    php-ldap \
    php-pgsql \
    php-pspell \
    php-recode \
    php-snmp \
    php-tidy \
    php-dev \
    php-curl \
    php-xdebug \
    nginx

# Install supervisor
RUN apt-get install -y supervisor

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir /var/www/html/

ADD files /

RUN useradd -M nginx \
    && rm /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default \
    && touch /var/log/php-fpm.log \
    && chown nginx:nginx /var/log/php-fpm.log \
    && chown -R nginx:nginx /var/run \
    && touch /var/log/nginx/access.log \
    && touch /var/log/nginx/error.log \
    && chown -R nginx:nginx /var/log/nginx/ \
    && mkdir -p /var/lib/nginx/logs \
    && touch /var/lib/nginx/logs/error.log \
    && chown nginx:nginx /var/lib/nginx/logs/error.log \
    && mkdir -p /run/php

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} && \
sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" ${fpm_conf} && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} && \
sed -i -e "s/pm.max_children = 4/pm.max_children = 4/g" ${fpm_conf} && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" ${fpm_conf} && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" ${fpm_conf} && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" ${fpm_conf} && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" ${fpm_conf} && \
sed -i -e "s/user = nobody/user = nginx/g" ${fpm_conf} && \
sed -i -e "s/group = nobody/group = nginx/g" ${fpm_conf} && \
sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" ${fpm_conf} && \
sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" ${fpm_conf} && \
sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" ${fpm_conf} && \
sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_conf}

RUN setcap cap_net_bind_service=ep /usr/sbin/nginx


WORKDIR /var/www/html/docroot
EXPOSE 443 80

CMD ["/start.sh"]