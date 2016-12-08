
all: push

TAG = $(shell git rev-parse --abbrev-ref HEAD | tr -d '\n')
PREFIX = drud/nginx-php-fpm
LOCALPREFIX = drud/nginx-php-fpm-local

binary:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o base/files/usr/bin/git-sync ./git-sync/main.go

dev: binary
	docker build -t $(PREFIX):$(TAG) base
	docker build -t $(LOCALPREFIX):$(TAG) local


latest: dev
	docker tag $(PREFIX):$(TAG) $(PREFIX):latest
	docker tag $(PREFIX):$(TAG) $(PREFIX):latest

canary: dev
	docker push $(PREFIX):$(TAG)
	docker push $(LOCALPREFIX):$(TAG)

all: latest canary
	docker push $(PREFIX):latest
	docker push $(LOCALPREFIX):latest