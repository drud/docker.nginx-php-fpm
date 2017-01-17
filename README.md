# Docker NGINX PHP7 FPM

## Introduction
This is a Dockerfile to build a container image for NGINX and PHP7 in FPM with production configurations. The container leverages [git-sync](https://github.com/drud/docker.git-sync) to facilitate cloning a website repository into the container.

## Building and pushing to dockerhub

To push a new version to hub.docker.com 
```
make TAG=x.x.x taggedpush"
```

If you omit setting the TAG on the build, it will try to use the branch you're on as the tag.

## Running
To simply run the container:
```
sudo docker run -d drud/nginx-php-fpm7
```
