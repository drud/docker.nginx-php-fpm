#
# XhProf + XhGui Dockerfile
# git@github.com:monsieurchico/docker-xhprof.git
#
FROM ubuntu:14.04
MAINTAINER Brad Bowman <brad@drud.com>

ENV php_conf /etc/php5/cli/php.ini
ENV fpm_conf /etc/php5/fpm/php-fpm.conf

# prevent debian errors
ENV DEBIAN_FRONTEND noninteractive

# prepare
RUN \
    mkdir -p /var/www && \
    mkdir -p /data/xhprof && \
    mkdir -p /data/db && \
    mkdir -p /var/log/php5-fpm && \
    apt-get update && \
    apt-get -y install \
        software-properties-common \
        python-software-properties \
        python-setuptools && \
    add-apt-repository ppa:nginx/development && \
    add-apt-repository ppa:ondrej/php5-5.6 && \
    add-apt-repository ppa:git-core/ppa

# install nginx
RUN \
  apt-get install -y nginx && \
  sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
  sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
  echo "daemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# install php
RUN \
    apt-get -y install \
        php5-fpm \
        php5-cli \
        php5-mysql \
        php5-mcrypt \
        php5-mongo \
        php5-xhprof \
        php5-dev \
        autoconf g++ make openssl libssl-dev libcurl4-openssl-dev \
        libcurl4-openssl-dev pkg-config \
        libsasl2-dev \
        mongodb && \
    pecl install mongodb && \
    rm -f /etc/php5/fpm/conf.d/* && \
    rm -f /etc/php5/cli/conf.d/* && \
    ln -sfv /etc/php5/mods-available/*.ini /etc/php5/fpm/conf.d && \
    ln -sfv /etc/php5/mods-available/*.ini /etc/php5/cli/conf.d && \
    sed -i -e "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|g" $php_conf && \
    sed -i -e "s|upload_max_filesize\s*=\s*2M|upload_max_filesize = 100M|g" $php_conf && \
    sed -i -e "s|post_max_size\s*=\s*8M|post_max_size = 100M|g" $php_conf && \
    sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" $fpm_conf && \
    sed -i -e "s|error_log.*|error_log = /var/log/php5-fpm.default.log|g" $fpm_conf && \
    sed -i -e "s|;catch_workers_output\s*=\s*yes|catch_workers_output = yes|g" $fpm_conf && \
    find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# install supervisor
RUN \
    apt-get install -y supervisor && \
    /usr/bin/easy_install supervisor && \
    /usr/bin/easy_install supervisor-stdout

# install xhgui
RUN \
    apt-get install -y git curl && \
    cd /var/www && \
    git clone https://github.com/perftools/xhgui.git && \
    cd xhgui && \
    php install.php && \
    php composer.phar --no-dev install

# clean
RUN \
     apt-get autoremove -y --purge \
        git \
        software-properties-common \
        python-software-properties \
        python-setuptools && \
    rm -rf /var/lib/apt/lists/*


ADD conf/php.ini /etc/php5/
ADD conf/supervisord-local.conf /etc/supervisord-local.conf
ADD conf/supervisord-remote.conf /etc/supervisord-remote.conf
# Copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf


# nginx site conf
RUN useradd nginx && \
mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/html && \
mkdir /var/www/html/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default
ADD conf/xhprof-site.conf /etc/nginx/sites-available/xhprof
ADD conf/www.conf /etc/php5/fpm/pool.d/www.conf

RUN rm /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/xhprof /etc/nginx/sites-enabled/xhprof \
    && touch /var/log/php-fpm.log \
    && chown nginx:nginx /var/log/php-fpm.log \
    && chown -R nginx:nginx /var/run \
    && touch /var/log/nginx/access.log \
    && touch /var/log/nginx/error.log \
    && chown -R nginx:nginx /var/log/nginx/ \
    && mkdir -p /var/lib/nginx/logs \
    && touch /var/lib/nginx/logs/error.log \
    && chown nginx:nginx /var/lib/nginx/logs/error.log

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

# Add Scripts
ADD bin/unison /usr/bin/
ADD bin/unison-fsmonitor /usr/bin/
ADD bin/mntwatch /usr/bin/
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push
RUN chmod 755 /start.sh
RUN setcap cap_net_bind_service=ep /usr/sbin/nginx

WORKDIR /var/www/html/docroot
EXPOSE 443 80 33333

CMD ["/start.sh"]

