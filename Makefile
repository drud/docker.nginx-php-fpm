# Makefile for a standard golang repo with associated container

##### These variables need to be adjusted in most repositories #####

# This repo's root import path (under GOPATH).
#PKG := github.com/drud/docker.nginx-php-fpm

# Docker repo for a push
DOCKER_REPO ?= drud/nginx-php-fpm7

# Upstream repo used in the Dockerfile
UPSTREAM_PHP_REPO_TAG ?= v0.2.0
UPSTREAM_REPO ?= drud/php7:$(UPSTREAM_PHP_REPO_TAG)

# Top-level directories to build
SRC_DIRS := git-sync

# Optional to docker build
DOCKER_ARGS = --build-arg DRUSH_VERSION=8.1.8 --build-arg NGINX_VERSION=1.11.8-1~jessie --build-arg WP_CLI_VERSION=1.0.0

# VERSION can be set by
  # Default: git tag
  # make command line: make VERSION=0.9.0
# It can also be explicitly set in the Makefile as commented out below.

# This version-strategy uses git tags to set the version string
# VERSION can be overridden on make commandline: make VERSION=0.9.1 push
VERSION := $(shell git describe --tags --always --dirty)
#
# This version-strategy uses a manual value to set the version string
#VERSION := 1.2.3

# Each section of the Makefile is included from standard components below.
# If you need to override one, import its contents below and comment out the
# include. That way the base components can easily be updated as our general needs
# change.
include build-tools/makefile_components/base_build_go.mak
include build-tools/makefile_components/base_build_python-docker.mak
include build-tools/makefile_components/base_container.mak
include build-tools/makefile_components/base_push.mak
#include build-tools/makefile_components/base_test_go.mak
#include build-tools/makefile_components/base_test_python.mak

test: containertest gitsynctest

containertest: build gitsynctest container
	@docker stop php7 2>/dev/null || true
	@docker rm php7 2>/dev/null || true
	docker run -p 1080:80 -d --name php7 -d $$(awk '{print $$1}' .docker_image)
	sleep 2 && curl --fail localhost:1080/healthcheck
	curl -s localhost:1080/test/test.php | grep "copy of the PHP license"
	@docker stop php7

gitsynctest: build
	@mkdir -p bin/linux
	@mkdir -p .go/src/$(PKG) .go/pkg .go/bin .go/std/linux
	@docker run -t --rm  -u $(shell id -u):$(shell id -g)                 \
	    -v $$(pwd)/.go:/go                                                 \
	    -v $$(pwd):/go/src/$(PKG)                                          \
	    -v $$(pwd)/bin/linux:/go/bin                                     \
	    -v $$(pwd)/.go/std/linux:/usr/local/go/pkg/linux_amd64_static  \
	    -e CGO_ENABLED=0	\
	    -w /go/src/$(PKG)                                                  \
	    $(BUILD_IMAGE)                                                     \
	    /bin/bash -c '                                                    \
	        GOOS=`uname -s |  tr "[:upper:]" "[:lower:]"`  &&		\
	        go test -v -installsuffix static -ldflags "$(LDFLAGS)" $(SRC_AND_UNDER)   \
	    '
