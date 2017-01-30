
# Normal usage to push a new version to hub.docker.com would be "make TAG=x.x.x taggedpush"
# TAG should be overridden with the make command, like make TAG=0.0.2 taggedpush
TAG = $(shell git rev-parse --abbrev-ref HEAD | tr -d '\n')

PREFIX = drud/nginx-php-fpm

binary:
	CGO_ENABLED=0 GOOS=linux go build -installsuffix cgo -ldflags '-w' -o files/usr/bin/git-sync ../git-sync/main.go

dev: binary
	docker build -t $(PREFIX):$(TAG) .

latest: dev
	docker tag $(PREFIX):$(TAG) $(PREFIX):latest .

taggedpush: dev
	docker push $(PREFIX):$(TAG)

