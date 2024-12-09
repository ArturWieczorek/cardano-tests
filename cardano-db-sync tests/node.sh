#!/bin/bash

function show_tips()
{
cat << EOF

To run node for desired network(s) use following commands from ${PWD}:

MAINNET:

./cardano-node run --topology mainnet/mainnet-topology.json \
--database-path mainnet/db \
--socket-path mainnet/node.socket \
--config mainnet/mainnet-config.json

TESTNET:

./cardano-node run --topology testnet/testnet-topology.json \
--database-path testnet/db \
--socket-path testnet/node.socket \
--config testnet/testnet-config.json

SHELLEY-QA:

./cardano-node run --topology shelley_qa/shelley_qa-topology.json \
--database-path shelley_qa/db \
--socket-path shelley_qa/node.socket \
--config shelley_qa/shelley_qa-config.json

STAGING:

./cardano-node run --topology staging/staging-topology.json \
--database-path staging/db \
--socket-path staging/node.socket \
--config staging/shelley_qa-config.json


ALLEGRA:

./cardano-node run --topology allegra/allegra-topology.json \
--database-path allegra/db \
--socket-path allegra/node.socket \
--config allegra/allegra-config.json

MARY-QA:

./cardano-node run --topology mary_qa/mary_qa-topology.json \
--database-path mary_qa/db \
--socket-path mary_qa/node.socket \
--config mary_qa/mary_qa-config.json

LAUNCHPAD:

./cardano-node run --topology launchpad/launchpad-topology.json \
--database-path launchpad/db \
--socket-path launchpad/node.socket \
--config launchpad/launchpad-config.json

EOF
}

function usage()
{
    cat << HEREDOC

    arguments:
      -n --network        network - possible options: allegra, launchpad, mary_qa, mainnet, staging, testnet, shelley_qa

    optional arguments:
      -h --help           show this help message and exit

Example:

./node.sh -n shelley_qa

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

IOHK_ROOT_REPO="input-output-hk"
NODE_REPO="${IOHK_ROOT_REPO}/cardano-node"

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}

echo "We are here: ${PWD}, script name is $0"
echo ""
echo "Creating cardano-node directory and entering it ..."

mkdir cardano-node
cd cardano-node

NODE_LATEST_TAG=$(get_latest_release ${NODE_REPO})


echo ""
echo "Downloading latest version of cardano-node tag: $NODE_LATEST_TAG"

wget -q --show-progress "https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest-finished/download/1/cardano-node-$NODE_LATEST_TAG-linux.tar.gz"

echo ""
echo "Unpacking and removing archive ..."

tar -xf "cardano-node-$NODE_LATEST_TAG-linux.tar.gz"
rm "cardano-node-$NODE_LATEST_TAG-linux.tar.gz"

NODE_CONFIGS_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | sed 's|\(.*\)/.*|\1|')

echo ""
echo "Downloading node configuration files from $NODE_CONFIGS_URL for networks specified in script ..."
echo ""

# Get latest configs for network(s) you need:
# List of all current networks: "allegra" "launchpad" "mainnet" "mary_qa" "shelley_qa" "staging" "testnet"

for _network in ${network}
do
	mkdir ${_network}
	cd ${_network}
	echo "${PWD}"
	wget -q --show-progress $NODE_CONFIGS_URL/${_network}-config.json
	wget -q --show-progress $NODE_CONFIGS_URL/${_network}-byron-genesis.json
	wget -q --show-progress $NODE_CONFIGS_URL/${_network}-shelley-genesis.json
	wget -q --show-progress $NODE_CONFIGS_URL/${_network}-topology.json
	wget -q --show-progress $NODE_CONFIGS_URL/${_network}-db-sync-config.json
	echo ""
	cd ..
done

echo ""
echo "Node configuration files located in ${PWD}:"
echo ""

ls -1

echo ""
echo "Node version: "
echo ""
./cardano-node --version

echo ""
echo "CLI version: "
echo ""
./cardano-cli --version


echo ""
echo ""
echo "Do you want to run node for specified network now ? Default is yes, enter N/n/No/no if you don't want to start node."
read decision

if [ "$decision" = "N"  ] || [ "$decision" = "n" ] || [ "$decision" = "No" ] || [ "$decision" = "no" ]
then
	show_tips
else
 ./cardano-node run --topology ${network}/${network}-topology.json --database-path ${network}/db --socket-path ${network}/node.socket --config ${network}/${network}-config.json

fi


: <<'COMMENT'

Downloading binaries for specific PR:

for example we have this PR: https://github.com/input-output-hk/cardano-node/pull/1983

To get all all evals use:

curl -H "Content-Type: application/json" https://hydra.iohk.io/jobset/Cardano/cardano-node-pr-1983/evals | jq

To download link for most recent build on PR for linux, mac and win use:

LINUX:
https://hydra.iohk.io/job/Cardano/cardano-node-pr-1983/cardano-node-linux/latest-finished/download/1/cardano-node-1.21.2-linux.tar.gz

MAC-OS:
https://hydra.iohk.io/job/Cardano/cardano-node-pr-1983/cardano-node-macos/latest-finished/download/1/cardano-node-1.21.2-macos.tar.gz

WINDOWS:
https://hydra.iohk.io/job/Cardano/cardano-node-pr-1983/cardano-node-win64/latest-finished/download/1/cardano-node-1.21.2-win64.zip

this will get you pre-build binaries. Remove the -pr-1983 part to get master

To get a list of all builds on master use:

https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux

To get commit details:

curl -H "Content-Type: application/json" https://hydra.iohk.io/jobset/Cardano/cardano-node/evals | jq .evals[].jobsetevalinputs

This can be scripted with help from:
https://github.com/input-output-hk/iohk-nix/blob/master/ci/hydra-eval-errors/bin/hydra-eval-errors.py

def loadEvalByCommit(self, commit, retries=60, retry_time=60):
        print(f"Attempting to find eval for commit: {commit}")
        retry_count = 0
        found = False
        while not found and retry_count < retries:
            try:
                hydra_evals = self.getApi(f"{self.jobPath}/evals")
                for hydra_eval in hydra_evals["evals"]:
                    if hydra_eval["jobsetevalinputs"][self.repo]["revision"] == commit:
                        found = True
                        self.evalId = hydra_eval["id"]
                        self.eval = self.getApi(f"eval/{self.evalId}")
                if not found:
                    raise ApiNotFoundError(f"Eval not created")
            except ApiNotFoundError as e:
                print(f"Hydra eval not created yet for {commit} - sleeping {retry_time} seconds")
                retry_count = retry_count + 1
                sleep(retry_time)
                if retry_count == retries:
                    print("Retried 1 hour - exiting")
                    errormsg = self.job["errormsg"]
                    print("Errors below may be incomplete")
                    print(f"An error occurred in evaluation:\n{errormsg}")
                    raise e


Helpful Slack Thread:
https://input-output-rnd.slack.com/archives/GR599HMFX/p1602765743326900

COMMENT
