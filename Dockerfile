FROM drud/nginx-php-fpm:1.1

ENV DRUSH_VERSION 8.1.2
ENV PATH="/root/.composer/vendor/bin:$PATH"


# Install Drush
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
    chmod +x /usr/local/bin/drush
