FROM golang:1.16-alpine as asc

RUN apk add --no-cache make gcc musl-dev linux-headers git bash

ADD . /asc
WORKDIR /asc
RUN make geth
RUN mv /asc/build/bin/geth /usr/local/bin/geth

EXPOSE 8545 8547 30303 30303/udp
ENTRYPOINT [ "/usr/local/bin/geth" ]

FROM ethereum/solc:0.6.4-alpine as asc-genesis

RUN apk add --d --no-cache ca-certificates npm nodejs bash alpine-sdk

RUN git clone https://github.com/aximchain/genesis-contract.git /root/genesis \
    && rm /root/genesis/package-lock.json && cd /root/genesis && npm install

COPY docker/init_holders.template /root/genesis/init_holders.template

COPY --from=asc /usr/local/bin/geth /usr/local/bin/geth

ENTRYPOINT [ "/bin/bash" ]
