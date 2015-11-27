FROM golang:1.4-onbuild
RUN groupadd user && useradd --create-home --home-dir /home/user -g user user
USER user
VOLUME ["/home/user"]
ENV GIT_SYNC_DEST /git
ENTRYPOINT ["/go/bin/git-sync"]
