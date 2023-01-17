#!/bin/bash
set -e

AXC_CONFIG=${AXC_HOME}/config/config.toml
AXC_GENESIS=${AXC_HOME}/config/genesis.json

# Init genesis state if geth not exist
DATA_DIR=$(cat ${AXC_CONFIG} | grep -A1 '\[Node\]' | grep -oP '\"\K.*?(?=\")')

GETH_DIR=${DATA_DIR}/geth
if [ ! -d "$GETH_DIR" ]; then
  geth --datadir ${DATA_DIR} init ${AXC_GENESIS}
fi

exec "geth" "--config" ${AXC_CONFIG} "$@"
