#!/bin/bash

set -e
# set -x

# This script creates, signs, and submits a transaction that creates some new tokens.
# It uses the output of the transaction from update-4.sh.

#ROOT=example
COINS_IN_INPUT=100000000000
#pushd ${ROOT}

export CARDANO_NODE_SOCKET_PATH=/home/artur/Projects/db-sync-8/cardano-node/mary-qa/node.socket

mkdir -p ma
cardano-cli address key-gen \
             --verification-key-file ma/policy.vkey \
             --signing-key-file ma/policy.skey

KEYHASH=$(cardano-cli address key-hash --payment-verification-key-file ma/policy.vkey)

SCRIPT=ma/policy.script
rm -f $SCRIPT
echo "{" >> $SCRIPT
echo "  \"keyHash\": \"${KEYHASH}\"," >> $SCRIPT
echo "  \"type\": \"sig\"" >> $SCRIPT
echo "}" >> $SCRIPT

#TXID3=

POLICYID=$(cardano-cli transaction policyid --script-file ma/policy.script)

cardano-cli transaction build-raw \
             --mary-era \
             --fee 1000000 \
             --tx-in 24e8c16ae358d1a0d23332cb87c92bd562ee3eb57d771c94a6179cd4e33466ce#0 \
             --tx-out="$(cat extended-payment.addr)+99999000000+5 $POLICYID.arturcoin" \
             --mint="5 $POLICYID.couttscoin" \
             --out-file tx.txbody

cardano-cli transaction sign \
             --signing-key-file payment.skey \
             --signing-key-file ma/policy.skey \
             --script-file $SCRIPT \
             --testnet-magic 3 \
             --tx-body-file  tx.txbody \
             --out-file      tx.tx

cardano-cli transaction submit --tx-file  tx.tx --testnet-magic 3


#popd
