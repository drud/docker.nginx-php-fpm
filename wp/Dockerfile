FROM drud/nginx-php-fpm:1.2

ENV TERM xterm

RUN apk update && apk add less

ADD files/ /
WORKDIR /var/www/html/docroot
