FROM nginx:mainline-alpine

MAINTAINER ngineered <support@ngineered.co.uk>

ENV php_conf /etc/php5/php.ini
ENV fpm_conf /etc/php5/php-fpm.conf
ENV DRUSH_VERSION 8.1.2
ENV MAILHOG_VERSION 0.2.1
ENV PATH="/root/.composer/vendor/bin:$PATH"

RUN apk update && apk add --no-cache bash less \
    openssh-client \
    wget \
    supervisor \
    curl \
    git \
    alpine-sdk \
    php5-fpm \
    php5-pdo \
    mysql-client \
    libcap \
    php5-pdo_mysql \
    php5-mysql \
    php5-mysqli \
    php5-mcrypt \
    php5-ctype \
    php5-zlib \
    php5-gd \
    php5-intl \
    php5-memcache \
    php5-sqlite3 \
    php5-pgsql \
    php5-xml \
    php5-xsl \
    php5-curl \
    php5-openssl \
    php5-iconv \
    php5-json \
    php5-soap \
    php5-phar \
    php5-dom && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    mkdir -p /etc/nginx && \
    mkdir -p /var/www/app && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
    chmod +x /usr/local/bin/drush

RUN git clone http://github.com/bmc/daemonize.git \
    && cd daemonize \
    && sh configure \
    && make \
    && make install \
    && rm -rf /daemonize

# Add Scripts
ADD files /

RUN mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf && \
    touch /var/log/php-fpm.log && \
    chown nginx:nginx /var/log/php-fpm.log && \
    chown -R nginx:nginx /var/run && \
    touch /var/log/nginx/access.log && \
    touch /var/log/nginx/error.log && \
    chown -R nginx:nginx /var/log/nginx/ && \
    mkdir -p /var/lib/nginx/logs && \
    touch /var/lib/nginx/logs/error.log && \
    chown nginx:nginx /var/lib/nginx/logs/error.log && \
    chmod ugo+x /usr/local/bin/* && \
    chmod ugo+x /start.sh

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
    sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_conf} &&\
    ln -s /etc/php5/php.ini /etc/php5/conf.d/php.ini && \
    find /etc/php5/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

RUN chmod 755 /start.sh && \
    setcap cap_net_bind_service=ep /usr/sbin/nginx

ADD https://github.com/mailhog/MailHog/releases/download/v${MAILHOG_VERSION}/MailHog_linux_amd64 /usr/bin/mailhog

RUN chmod ugo+x /usr/bin/mailhog

EXPOSE 443 80 8025

CMD ["/start.sh"]

