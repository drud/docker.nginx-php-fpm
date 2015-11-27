FROM golang:1.4-onbuild
RUN groupadd user && useradd --create-home --home-dir /home/user -g user user
USER user
VOLUME ["/home/user"]
WORKDIR /home/user
ENV GIT_SYNC_DEST /home/user
ENTRYPOINT ["/go/bin/git-sync"]
