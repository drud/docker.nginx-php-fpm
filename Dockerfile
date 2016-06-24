FROM drud/nginx-php-fpm

ENV DRUSH_VERSION 7.3.0
ENV PATH="/root/.composer/vendor/bin:$PATH"

# Install Drush using Composer.
RUN composer global require drush/drush:"$DRUSH_VERSION" --prefer-dist

ADD files/ /