# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.17-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git bash
# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum
RUN cd /go-ethereum && go run build/ci.go install ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:3.16.0

ARG AXC_USER=axc
ARG AXC_USER_UID=1000
ARG AXC_USER_GID=1000

ENV AXC_HOME=/axc
ENV HOME=${AXC_HOME}
ENV DATA_DIR=/data

ENV PACKAGES ca-certificates~=20220614-r0 jq~=1.6 \
  bash~=5.1.16-r2 bind-tools~=9.16.33 tini~=0.19.0 \
  grep~=3.7 curl~=7.83.1 sed~=4.8-r0

RUN apk add --no-cache $PACKAGES \
  && rm -rf /var/cache/apk/* \
  && addgroup -g ${AXC_USER_GID} ${AXC_USER} \
  && adduser -u ${AXC_USER_UID} -G ${AXC_USER} --shell /sbin/nologin --no-create-home -D ${AXC_USER} \
  && addgroup ${AXC_USER} tty \
  && sed -i -e "s/bin\/sh/bin\/bash/" /etc/passwd  

RUN echo "[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash/bashrc

WORKDIR ${AXC_HOME}

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

COPY docker-entrypoint.sh ./

RUN chmod +x docker-entrypoint.sh \
    && mkdir -p ${DATA_DIR} \
    && chown -R ${AXC_USER_UID}:${AXC_USER_GID} ${AXC_HOME} ${DATA_DIR}

VOLUME ${DATA_DIR}

USER ${AXC_USER_UID}:${AXC_USER_GID}

# rpc ws graphql
EXPOSE 8545 8546 8547 30303 30303/udp

ENTRYPOINT ["/sbin/tini", "--", "./docker-entrypoint.sh"]
