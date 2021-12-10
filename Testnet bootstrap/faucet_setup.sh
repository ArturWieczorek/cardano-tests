#!/usr/bin/env bash

set -euo pipefail

TESTNET_MAGIC="${TESTNET_MAGIC:-7}"
TESTNET_NAME="${TESTNET_NAME:-alonzo-white}"
APIKEY="${APIKEY:-jv3NBtZeaL0lZUxgqq8slTttX3BzViI7}"

if [ ! -e shelley/faucet.addr ]; then
  echo "Creating faucet address"
  mkdir -p shelley
  cardano-cli address key-gen --verification-key-file shelley/faucet.vkey --signing-key-file shelley/faucet.skey
  cardano-cli address build --payment-verification-key-file shelley/faucet.vkey --testnet-magic "$TESTNET_MAGIC" --out-file shelley/faucet.addr
fi

ADDR="$(<shelley/faucet.addr)"
echo "Fund the faucet address '$ADDR'? Press Ctrl+C to cancel."
read -r

curl -v -XPOST "https://faucet.${TESTNET_NAME}.dev.cardano.org/send-money/${ADDR}?apiKey=${APIKEY}"
sleep 10
cardano-cli query utxo --out-file /dev/stdout --testnet-magic "$TESTNET_MAGIC" --address "$ADDR"
echo
