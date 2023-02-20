#!/bin/bash
set -e

ASC_CONFIG=${ASC_HOME}/config/config.toml
ASC_GENESIS=${ASC_HOME}/config/genesis.json

# Init genesis state if geth not exist
DATA_DIR=$(cat ${ASC_CONFIG} | grep -A1 '\[Node\]' | grep -oP '\"\K.*?(?=\")')

GETH_DIR=${DATA_DIR}/geth
if [ ! -d "$GETH_DIR" ]; then
  geth --datadir ${DATA_DIR} init ${ASC_GENESIS}
fi

exec "geth" "--config" ${ASC_CONFIG} "$@"
