# 0.0 shouldn't clobber any released builds
TAG = $(shell git rev-parse --abbrev-ref HEAD | tr -d '\n')
PREFIX = drud/git-sync

binary: git-sync/main.go liveness/main.go
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o git-sync/git-sync ./git-sync/main.go
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o liveness/liveness ./liveness/main.go

dev: binary
	docker build -t $(PREFIX):$(TAG) .

latest: dev
	docker tag $(PREFIX):$(TAG) $(PREFIX):latest

canary: dev
	docker push $(PREFIX):$(TAG)

all: latest canary
	docker push $(PREFIX):latest

clean:
	docker rmi -f $(PREFIX):$(TAG) || true
	docker rmi -f $(PREFIX):latest || true
	rm liveness/liveness
	rm git-sync/git-sync
