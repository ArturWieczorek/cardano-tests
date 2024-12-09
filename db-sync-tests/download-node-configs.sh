#!/bin/bash

function usage()
{
    cat << HEREDOC
    Usage: $progname [--help] [--mode]
    optional arguments:
      -h          show this help message and exit
      -n          network - possible options: allegra, launchpad, mary_qa, mainnet, staging, testnet, shelley_qa

Example:

./download-node-configs.sh -n shelley_qa -n mary_qa -n mainnet -n staging -n testnet -n launchpad
HEREDOC
}

if [ $? != 0 ] || [ $# == 0 ] ; then
    echo "ERROR: Error in command line arguments." >&2 ; usage; exit 1 ;
fi


while getopts "hn:" opt; do
    case $opt in
        h) usage ; exit; ;;
        n) networks+=("$OPTARG");;
    esac
done
shift $((OPTIND -1))


NODE_CONFIGS_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | sed 's|\(.*\)/.*|\1|')

echo ""
echo "Downloading node configuration files from $NODE_CONFIGS_URL for networks specified in script ..."
echo ""


# Get latest configs for network(s) you need:
# List of all current networks: "allegra" "launchpad" "mainnet" "mary_qa" "shelley_qa" "staging" "testnet"

for network in "${networks[@]}"
do
	mkdir ${network}
	cd ${network}
	echo "${PWD}"
	wget -q --show-progress $NODE_CONFIGS_URL/${network}-config.json
	wget -q --show-progress $NODE_CONFIGS_URL/${network}-byron-genesis.json
	wget -q --show-progress $NODE_CONFIGS_URL/${network}-shelley-genesis.json
	wget -q --show-progress $NODE_CONFIGS_URL/${network}-topology.json
	wget -q --show-progress $NODE_CONFIGS_URL/${network}-db-sync-config.json
	echo ""
	cd ..
done


echo ""
echo "Copy directories with configs to cardano-node directory."
echo ""
