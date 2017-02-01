# Docker NGINX PHP FPM

## Introduction
This is a Dockerfile to build a container image for NGINX and PHP in FPM with production configurations. 

## Features

* The container leverages [git-sync](https://github.com/drud/docker.git-sync) to facilitate cloning a website repository into the container.
* Provides [Composer](https://getcomposer.org/), [Drush](http://www.drush.org), and [WP-CLI](http://www.wp-cli.org) to help facilitate deploying PHP, Drupal, or Wordpress applications.

## Versions

This repo currently provides images to use either PHP 7 or PHP 5.6. 

The PHP 5.6 version is alpine-based and originally forked from [ngineered/nginx-php-fpm](https://github.com/ngineered/nginx-php-fpm)

The PHP 7 version is based on our [PHP7 container](https://github.com/drud/docker.php7) which is based on [minideb](https://github.com/bitnami/minideb)

## Building and pushing to dockerhub

Standard build targets are provided both at the top-level Makefile and the individual Makefiles in the php56 and php7 directories.

```
make linux
make darwin
make test
make container
make push
make VERSION=0.1.0 container
make VERSION=0.1.0 push
make version
make clean
```

## Running
To simply run the container:

PHP5.6 version:
```
sudo docker run -d drud/nginx-php-fpm
```

PHP7 version:
```
sudo docker run -d drud/nginx-php-fpm7
```
