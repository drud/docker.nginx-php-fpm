all: push

# 0.0 shouldn't clobber any released builds
TAG = latest
PREFIX = drud/git-sync

binary: git-sync/main.go liveness/main.go
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o git-sync/git-sync ./git-sync/main.go
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o liveness/liveness ./liveness/main.go

container: binary
	docker build -t $(PREFIX):$(TAG) .

push: container
	docker push $(PREFIX):$(TAG)

clean:
	docker rmi -f $(PREFIX):$(TAG) || true
