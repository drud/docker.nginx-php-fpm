## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm, with the ability to pull website code from git. The container also has the ability to update templated files with vaiables passed to docker in order to update your settings.

Forked from https://github.com/ngineered/nginx-php-fpm. The [README there](https://github.com/ngineered/nginx-php-fpm/blob/master/README.md) is useful.

## Building and pushing to dockerhub

To push a new version to hub.docker.com 
```
make TAG=x.x.x taggedpush"
```

If you omit setting the TAG on the build, it will try to use the branch you're on as the tag.

## Running
To simply run the container:
```
sudo docker run -d drud/nginx-php-fpm
```

You can then browse to ```http://<DOCKER_HOST>:8080``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` to get the IP address.
