# FROM golang:1.16-alpine as axc

# RUN apk add --no-cache make gcc musl-dev linux-headers git bash

# ADD . /axc
# WORKDIR /axc
# RUN make geth
# RUN mv /axc/build/bin/geth /usr/local/bin/geth && chmod +x /usr/local/bin/geth

# EXPOSE 8545 8547 30303 30303/udp
# ENTRYPOINT [ "/usr/local/bin/geth" ]

# FROM ethereum/solc:0.6.4-alpine as axc-genesis

# RUN apk add --d --no-cache ca-certificates npm nodejs bash alpine-sdk

# RUN git clone https://github.com/binance-chain/bsc-genesis-contract.git /root/genesis \
#     && rm /root/genesis/package-lock.json && cd /root/genesis && npm install

# COPY docker/init_holders.template /root/genesis/init_holders.template

# COPY --from=axc /usr/local/bin/geth /usr/local/bin/geth

# ENTRYPOINT [ "/bin/bash" ]

FROM golang:1.16-alpine as axc
RUN apk add --no-cache make gcc musl-dev linux-headers git bash
WORKDIR /axc
ADD . .
RUN make geth && \
    cp /axc/build/bin/geth /usr/bin \
    && chmod +x /usr/bin/geth

FROM ethereum/solc:0.6.4-alpine as axc-genesis
RUN apk add --d --no-cache ca-certificates npm nodejs bash alpine-sdk
RUN git clone https://github.com/Sotatek-AnhDao/axc-genesis-contract.git /root/genesis \
    && rm /root/genesis/package-lock.json && cd /root/genesis && npm install

COPY docker/init_holders.template /root/genesis/init_holders.template
COPY --from=axc /usr/bin/geth /usr/bin/geth
EXPOSE 8545 8547 30303 30303/udp
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]