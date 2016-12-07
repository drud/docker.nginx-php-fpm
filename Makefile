
all: push

TAG = $(shell git rev-parse --abbrev-ref HEAD | tr -d '\n')
prefix = drud/nginx-php-fpm

binary:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o container/files/usr/bin//git-sync ./git-sync/main.go

dev: binary
	docker build -t $(prefix):$(TAG) container

latest: dev
	docker tag $(prefix):$(TAG) $(prefix):latest

canary: dev
	docker push $(prefix):$(TAG)

all: latest canary
	docker push $(prefix):latest