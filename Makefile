# Makefile for a standard golang repo with associated container

##### These variables need to be adjusted in most repositories #####

# This repo's root import path (under GOPATH).
#PKG := github.com/drud/docker.site-deploy

# Docker repo for a push
# DOCKER_REPO ?= drud/docker_repo_name

# Upstream repo used in the Dockerfile
# UPSTREAM_REPO ?= full/upstream-docker-repo

# Top-level directories to build
#SRC_DIRS := php56 php7

# Optional to docker build
# DOCKER_ARGS =

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

# Our local "build" must be done first to build the "main" go app, which is copied into the subdirs


# Each section of the Makefile is included from standard components below.
# If you need to override one, import its contents below and comment out the
# include. That way the base components can easily be updated as our general needs
# change.
include build-tools/makefile_components/base_build_go.mak
#include build-tools/makefile_components/base_build_python-docker.mak
#include build-tools/makefile_components/base_container.mak
#include build-tools/makefile_components/base_push.mak
include build-tools/makefile_components/base_test_go.mak
#include build-tools/makefile_components/base_test_python.mak


container:
	$(MAKE) -C ./php56 $(MAKEFLAGS) $(MAKECMDGOALS)
	$(MAKE) -C ./php7 $(MAKEFLAGS) $(MAKECMDGOALS)

push: container
	$(MAKE) -C ./php56 $(MAKEFLAGS) $(MAKECMDGOALS)
	$(MAKE) -C ./php7 $(MAKEFLAGS) $(MAKECMDGOALS)

