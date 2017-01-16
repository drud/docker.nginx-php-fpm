FROM drud/php7:dev

ENV NGINX_VERSION 1.11.8-1~jessie
ENV DRUSH_VERSION 8.1.3
ENV WP_CLI_VERSION 1.0.0
ENV PATH="/root/.composer/vendor/bin:$PATH"

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
	echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
    ca-certificates \
    nginx=${NGINX_VERSION} \
    libcap2-bin \
    supervisor && \
    apt-get clean -y && \
	rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

ADD "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" /usr/bin/drush
ADD "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" /usr/bin/wp-cli
ADD files /

RUN mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf && \
    touch /var/log/php7.0-fpm.log && \
    chown nginx:nginx /var/log/php7.0-fpm.log && \
    chown -R nginx:nginx /var/run && \
    touch /var/log/nginx/access.log && \
    touch /var/log/nginx/error.log && \
    chown -R nginx:nginx /var/log/nginx/ && \
    mkdir -p /var/lib/nginx/logs && \
    touch /var/lib/nginx/logs/error.log && \
    chown nginx:nginx /var/lib/nginx/logs/error.log && \
    setcap cap_net_bind_service=ep /usr/sbin/nginx && \
    chmod ugo+x /usr/bin/* && \
    chmod ugo+x /start.sh

EXPOSE 80 443

CMD ["/start.sh"]
