#!/bin/bash

function usage()
{
    cat << HEREDOC

    arguments:
      -n, --network          network - possible options: allegra, launchpad, mary_qa, mainnet, staging, testnet, shelley_qa

    optional arguments:
      -h --help              show this help message and exit

Example:

./create-addresses.sh -n shelley_qa

USE UNDERSCORES IN NETWORK NAMES !!!
HEREDOC
}

OPTS=$(getopt -o "hn:" --long "help,network:" -n "$progname" -- "$@")
if [ $? != 0 ] || [ $# == 0 ] ; then
    echo "ERROR: Error in command line arguments." >&2 ; usage; exit 1 ;
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
        -h | --help ) usage; exit; ;;
        -n | --network ) network="$2"; shift 2 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

export CARDANO_NODE_SOCKET_PATH=${PWD}/cardano-node/${network}/node.socket

cd cardano-node

NETWORK_MAGIC=$(cat ${network}/${network}-shelley-genesis.json | grep networkMagic | grep -E -o "[0-9]+")

mkdir keys
cd keys

# Create keys & addresses:


# Regular Payment key pair - "Faucet" for our transactions

cardano-cli address key-gen \
--verification-key-file payment.vkey \
--signing-key-file payment.skey

# Regular Payment key pair 2

cardano-cli address key-gen \
--verification-key-file payment2.vkey \
--signing-key-file payment2.skey

# Extended Payment key pair

cardano-cli address key-gen --extended-key \
--verification-key-file extended-payment.vkey \
--signing-key-file extended-payment.skey

# Byron Payment key pair

cardano-cli address key-gen --byron-key \
--verification-key-file byron-payment.vkey \
--signing-key-file byron-payment.skey

# Stake key pair 1

cardano-cli stake-address key-gen \
--verification-key-file stake.vkey \
--signing-key-file stake.skey

# Stake key pair 2

cardano-cli stake-address key-gen \
--verification-key-file stake2.vkey \
--signing-key-file stake2.skey

# Stake key pair 3

cardano-cli stake-address key-gen \
--verification-key-file stake3.vkey \
--signing-key-file stake3.skey

# Stake key pair 4

cardano-cli stake-address key-gen \
--verification-key-file stake4.vkey \
--signing-key-file stake4.skey


# Regular Payment address

cardano-cli address build \
--payment-verification-key-file payment.vkey \
--stake-verification-key-file stake.vkey \
--out-file payment.addr \
--testnet-magic ${NETWORK_MAGIC}


# Extended Payment address

cardano-cli address build \
--payment-verification-key-file extended-payment.vkey \
--stake-verification-key-file stake2.vkey \
--out-file extended-payment.addr \
--testnet-magic ${NETWORK_MAGIC}


# Byron Payment address

cardano-cli address build \
--payment-verification-key-file byron-payment.vkey \
--stake-verification-key-file stake3.vkey \
--out-file byron-payment.addr \
--testnet-magic ${NETWORK_MAGIC}

# Regular Payment address 2

cardano-cli address build \
--payment-verification-key-file payment2.vkey \
--stake-verification-key-file stake4.vkey \
--out-file payment2.addr \
--testnet-magic ${NETWORK_MAGIC}

# Stake address 1

cardano-cli stake-address build \
--stake-verification-key-file stake.vkey \
--out-file stake.addr \
--testnet-magic ${NETWORK_MAGIC}

# Stake address 2

cardano-cli stake-address build \
--stake-verification-key-file stake2.vkey \
--out-file stake2.addr \
--testnet-magic ${NETWORK_MAGIC}


# Stake address 3

cardano-cli stake-address build \
--stake-verification-key-file stake3.vkey \
--out-file stake3.addr \
--testnet-magic ${NETWORK_MAGIC}

# Stake address 4

cardano-cli stake-address build \
--stake-verification-key-file stake4.vkey \
--out-file stake4.addr \
--testnet-magic ${NETWORK_MAGIC}


echo ""
echo "Created following addresses inside ${PWD}: "
ls -l

echo ""
echo "Regular Payment addresses --> payment.addr:"
cat payment.addr

echo ""
echo ""
echo "Regular Payment addresses 2 --> payment2.addr:"
cat payment2.addr

echo ""
echo ""
echo "Extended Payment addresses --> extended-payment.addr:"
cat extended-payment.addr

echo ""
echo ""
echo "Byron Payment addresses --> byron-payment.addr:"
cat byron-payment.addr

echo ""
echo ""
echo "Stake 1 address associated with Regular Payment addresses --> stake.addr :"
cat stake.addr

echo ""
echo ""
echo "Stake 2 address associated with Extended Payment addresses --> stake2.addr :"
cat stake2.addr

echo ""
echo ""
echo "Stake 3 address associated with Byron Payment addresses --> stake3.addr :"
cat stake3.addr
echo ""
echo ""

echo ""
echo ""
echo "Stake 4 address associated with Byron Payment addresses --> stake3.addr :"
cat stake4.addr
echo ""
echo ""
