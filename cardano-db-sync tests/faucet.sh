#!/bin/bash

function usage()
{
    cat << HEREDOC

     arguments:
       -n           network - possible options: allegra, launchpad, mary-qa, mainnet, staging, testnet, shelley-qa

     optional arguments:
       -h           show this help message and exit
       -a           address - payment address to charge e.g. addr_test1qzswfwun0k6yvdln9au69h00zwlc50hs2zkn20s3wh5p69gq79jkfepw3mdgpt9ml42yvdg50538yqsxl39nsts7gvws9sygmw

Example:

./faucet.sh -n shelley-qa

DON'T USE UNDERSCORES IN NETWORK NAMES !!!
HEREDOC
}

while getopts ":h:n:a:" o; do
    case "${o}" in
        h)
            usage
            ;;
        n)
            network=${OPTARG}
            ;;
        a)
            address=${OPTARG}
            ;;
        *)
            echo "NO SUCH ARGUMENT: ${OPTARG}"
            usage
            ;;
    esac
done
if [ $? != 0 ] || [ $# == 0 ] ; then
    echo "ERROR: Error in command line arguments." >&2 ; usage; exit 1 ;
fi
shift $((OPTIND-1))


cd cardano-node
cd keys

API_KEY=""

case "${network}" in

mary-qa)
    API_KEY=Xk4cN5mwkWh8NhO6O3bf41q4SEZjwY2g
    ;;
shelley-qa)
    API_KEY=Xk4cN5mwkWh8NhO6O3bf41q4SEZjwY2g
    ;;
testnet)
    API_KEY=HawnRyeOM94wntkYbLJNAhC8CuDf6kve
    ;;
launchpad)
    API_KEY=1s0BSND9DXVakVZHLdclh5HjYNQi3gKh
   ;;
*) echo "No such network"
   usage
   exit 1;
   ;;
esac

addr=${address:-$(cat payment.addr)}

echo "Would you like to request funds from faucet to charge Regular Payment addresses --> payment.addr or one specified directly as command option ? Default is Yes, enter N/n/No/no if you don't want to request funds from faucet."
read decision
if [ "$decision" = "N"  ] || [ "$decision" = "n" ] || [ "$decision" = "No" ] || [ "$decision" = "no" ]
then
	echo "Skipping request for funds"
else
    curl -v -XPOST "https://faucet.${network}.dev.cardano.org/send-money/${addr}?apiKey=${API_KEY}"

    echo ""
    echo "Checking address funds after transfer from faucet. If result is empty it means you have to wait more time for node to sync fully the chain"
    cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic ${NETWORK_MAGIC} --${ERA}-era
fi
