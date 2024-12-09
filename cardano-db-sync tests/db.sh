#!/bin/bash


function usage()
{
    cat << HEREDOC

    arguments:
      -n --network        network - possible options: allegra, launchpad, mary-qa, shelley-qa, mainnet, staging, testnet

    optional arguments:
      -h --help           show this help message and exit

Example:

./db.sh -n shelley-qa

DO NOT USE UNDERSCORES IN NETWORK NAMES FOR THIS SCRIPT !!!
HEREDOC
}

function show_tips()
{
cat << EOF

Useful Information:

Before starting db-sync or db-sync-extended you might need to drop database first:

psql -U postgres

List DBs:
\l

Get the name from the list and drop DB:
DROP DATABASE db_name

Exit from postgresql:
\q


In order to create DB and run it for specified network use:

MAINNET:

PGPASSFILE=config/pgpass-mainnet scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-mainnet db-sync-node/bin/cardano-db-sync \
--config config/mainnet-config.yaml \
--socket-path ../cardano-node/mainnet/node.socket \
--state-dir ledger-state/mainnet \
--schema-dir schema/


STAGING:

PGPASSFILE=config/pgpass-staging scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-staging db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/staging-config.yaml \
--socket-path ../cardano-node/staging/node.socket \
--state-dir ledger-state/staging \
--schema-dir schema/


TESTNET:

PGPASSFILE=config/pgpass-testnet scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-testnet db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/testnet-config.yaml \
--socket-path ../cardano-node/testnet/node.socket \
--state-dir ledger-state/testnet \
--schema-dir schema/


SHELLEY QA :

PGPASSFILE=config/pgpass-shelley-qa scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-shelley-qa db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/shelley-qa-config.yaml \
--socket-path ../cardano-node/shelley_qa/node.socket \
--state-dir ledger-state/shelley_qa \
--schema-dir schema/


MARY QA :

PGPASSFILE=config/pgpass-mary-qa scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-mary-qa db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/mary-qa-config.yaml \
--socket-path ../cardano-node/mary_qa/node.socket \
--state-dir ledger-state/mary_qa \
--schema-dir schema/


LAUNCHPAD :

PGPASSFILE=config/pgpass-launchpad scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-launchpad db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/launchpad-config.yaml \
--socket-path ../cardano-node/launchpad/node.socket \
--state-dir ledger-state/launchpad \
--schema-dir schema/

To build with cabal you might need first run:

cabal update

It is only needed ocassionally (once a month or so), then build:

cabal build all

and run executable with:

PGPASSFILE=config/pgpass-mainnet cabal run cardano-db-sync-extended -- \
--config config/mainnet-config.yaml \
--socket-path ../cardano-node/mainnet/node.socket \
--state-dir ledger-state/mainnet \
--schema-dir schema/

EOF
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
DB_SYNC_REPO="${IOHK_ROOT_REPO}/cardano-db-sync"

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}

echo "We are here: ${PWD}, script name is $0"
echo ""
echo "Cloning cardano-db-sync repository and entering it ..."

DB_SYNC_LATEST_TAG=$(get_latest_release ${DB_SYNC_REPO})

git clone https://github.com/input-output-hk/cardano-db-sync

cd cardano-db-sync
git checkout tags/${DB_SYNC_LATEST_TAG}

cd config

echo ""
echo "Creating config files for each network in ${PWD}:"

mv shelley-qa-testnet.yaml shelley-qa-config.yaml
mv pgpass-shelley-qa-testnet pgpass-shelley-qa

sed -i "s/cexplorer/mainnet/g" pgpass-mainnet
sed -i "s/shelley-test/shelley-qa/g" pgpass-shelley-qa

sed -i "s/NodeConfigFile.*/NodeConfigFile: ..\/..\/cardano-node\/mainnet\/mainnet-config.json/g" mainnet-config.yaml
sed -i "s/NodeConfigFile.*/NodeConfigFile: ..\/..\/cardano-node\/shelley_qa\/shelley_qa-config.json/g" shelley-qa-config.yaml

MODIFIED_NETWORK_NAME=""
for _network in "allegra" "launchpad" "mary-qa" "staging" "testnet"
do
	cp pgpass-mainnet "pgpass-${_network}"
    sed -i "s/mainnet/${_network}/g" "pgpass-${_network}"

	cp mainnet-config.yaml "${_network}-config.yaml"
	MODIFIED_NETWORK_NAME=$(echo "${_network}" | sed 's/-/_/')
	sed -i "s/NetworkName.*/NetworkName: ${_network}/g" "${_network}-config.yaml"
	sed -i "s/NodeConfigFile.*/NodeConfigFile: ..\/..\/cardano-node\/${MODIFIED_NETWORK_NAME}\/${MODIFIED_NETWORK_NAME}-config.json/g" "${_network}-config.yaml"
done

ls -l

cd ..

echo ""
echo "Building db-sync with nix ..."
echo ""
echo ""

nix-build -A cardano-db-sync -o db-sync-node

echo ""
echo "Building db-sync-extended with nix ..."
echo ""
echo ""

nix-build -A cardano-db-sync-extended -o db-sync-node-extended

echo ""
echo ""
echo "Do you want to delete DB before running db-sync (Yes/yes/Y/y) ? Default is No."
read decision1
if [ "$decision1" = "Y"  ] || [ "$decision1" = "y" ] || [ "$decision1" = "Yes" ] || [ "$decision1" = "yes" ]; then
	dropdb "${network}"
fi


echo ""
echo ""
echo "Do you want to run db-sync for specified network now ? Default is yes, enter N/n/No/no if you don't want to start db-sync."
read decision2
if [ "$decision2" = "N"  ] || [ "$decision2" = "n" ] || [ "$decision2" = "No" ] || [ "$decision2" = "no" ]
then
	show_tips
else
MODIFIED_NETWORK_NAME=$(echo "${network}" | sed 's/-/_/')

PGPASSFILE=config/pgpass-${network} scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-${network} db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/${network}-config.yaml \
--socket-path ../cardano-node/${MODIFIED_NETWORK_NAME}/node.socket \
--state-dir ledger-state/${MODIFIED_NETWORK_NAME} \
--schema-dir schema/

fi
