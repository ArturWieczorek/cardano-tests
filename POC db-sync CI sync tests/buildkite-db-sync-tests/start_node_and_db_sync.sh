#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix coreutils gnugrep gawk wget postgresql buildkite-agent

set -euo pipefail

function usage() {
    cat << HEREDOC
    arguments:
    -e          environment - possible options: allegra, launchpad, mary_qa, mainnet, staging, testnet, shelley_qa
    optional arguments:
    -h        show this help message and exit
Example:
./start_node.sh -e shelley_qa -t 1.25.0
USE UNDERSCORES IN environment NAMES !!!
HEREDOC
}

function get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}


while getopts ":h:e:" o; do
    case "${o}" in
        h)
            usage
            ;;
        e)
            environment=${OPTARG}
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

# Part of the script responsible for starting node

iohk_root_repo="input-output-hk"
node_repo="${iohk_root_repo}/cardano-node"
node_logfile="node_logfile.log"

echo "We are here: ${PWD}, script name is $0"
echo ""
echo "Creating cardano-node directory and entering it ..."

mkdir cardano-node
cd cardano-node
cardano_node_root_dir=${PWD}

node_latest_tag=$(get_latest_release ${node_repo})

echo ""
echo "Downloading latest version of cardano-node tag: $node_latest_tag"

wget -q "https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest-finished/download/1/cardano-node-$node_latest_tag-linux.tar.gz"

echo ""
echo "Unpacking and removing archive ..."

tar -xf "cardano-node-$node_latest_tag-linux.tar.gz"
rm "cardano-node-$node_latest_tag-linux.tar.gz"

NODE_CONFIGS_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | sed 's|\(.*\)/.*|\1|')

echo ""
echo "Downloading node configuration files from $NODE_CONFIGS_URL for environments specified in script ..."
echo ""

# Get latest configs for environment you need:
for _environment in ${environment}
do
	mkdir ${_environment}
	cd ${_environment}
	echo "${PWD}"
	wget -q  $NODE_CONFIGS_URL/${_environment}-config.json
	wget -q  $NODE_CONFIGS_URL/${_environment}-byron-genesis.json
	wget -q  $NODE_CONFIGS_URL/${_environment}-shelley-genesis.json
	wget -q  $NODE_CONFIGS_URL/${_environment}-topology.json
	wget -q  $NODE_CONFIGS_URL/${_environment}-db-sync-config.json
	echo ""
	cd ..
done

echo ""
echo "Node configuration files located in ${PWD}, inside directory $environment"

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
echo "Starting node."

./cardano-node run --topology ${environment}/${environment}-topology.json --database-path ${environment}/db --socket-path ${environment}/node.socket --config ${environment}/${environment}-config.json >> $node_logfile &

CARDANO_NODE_PID=$!

echo ""
echo "Sleeping for 5 seconds..."

sleep 5

cat $node_logfile

export CARDANO_NODE_SOCKET_PATH=/var/lib/buildkite-agent/builds/packet-ipxe-4-ci4-bench/input-output-hk/qa-db-sync-sync-test/cardano-node/${environment}/node.socket

cd ..
# End of part of the script responsible for starting node



# Part of the script responsible for starting db-sync

function get_network_param_value() {

	if [ "$environment" = "mainnet"  ]
	    then
	        echo "--mainnet"

	elif [ "$environment" = "testnet" ]
		then
	    	echo "--testnet-magic 1097911063"

	elif [ "$environment" = "staging" ]
		then
	    	echo "--testnet-magic 633343913"

	elif [ "$environment" = "shelley_qa" ]
		then
	    	echo "--testnet-magic 3"
	fi
}

function get_block_from_tip() {

	 ./../cardano-node/cardano-cli query tip $(get_network_param_value) |

	while read -r line
	do
		if [[ $line == *"block"* ]]; then
	    	IFS=' ' read -ra ADDR <<< "$line"
	      	echo "${ADDR[1]}" | sed 's/.$//'
		fi
	done
}

function get_latest_db_synced_slot() {

	local log_filepath=$1
	IN=$(tail -n 1 $log_filepath)
	preformated_string=$(echo "$IN" | sed 's/^.*slot/slot/') # this will return: "slot 19999, block 20000, hash 683be7324c47df71e2a234639a26d7747f1501addbba778636e66f3a18a46db7"

	IFS=' ' read -ra ADDR <<< "$preformated_string"
	for i in "${!ADDR[@]}"; do
		if [[ "${ADDR[$i]}" == *"slot"* ]]; then # we get the index $i for slot keyword - we know that slot number has ${i+1) position
	    	slot_number=$(echo "${ADDR[$((i+1))]}"| sed 's/.$//') # use sed to remove comma at the end of slot number
	       	echo $slot_number
	    fi
	done
}

function calculate_latest_node_slot_for_environment() {

	if [ "$environment" = "mainnet"  ]
	then
	        byron_start_time_in_seconds=1506203091   # 2017-09-23 21:44:51
	        shelley_start_time_in_seconds=1596059091 # 2020-07-29 21:44:51
	        allegra_start_time_in_seconds=1608155091 # 2020-12-16 21:44:51

	elif [ "$environment" = "testnet" ]
	then
	        byron_start_time_in_seconds=1563999616    # 2019-07-24 20:20:16
	        shelley_start_time_in_seconds=1595967616  # 2020-07-28 20:20:16
	        allegra_start_time_in_seconds=1608063616  # 2020-12-15 20:20:16

	elif [ "$environment" = "staging" ]
	then
	        byron_start_time_in_seconds=1506450213    # 2017-09-26 18:23:33
	        shelley_start_time_in_seconds=1596306213  # 2020-08-01 18:23:33
	        allegra_start_time_in_seconds=1608402213  # 2020-12-19 18:23:33

	elif [ "$environment" = "shelley_qa" ]
	then
	        byron_start_time_in_seconds=1597669200    # 2020-08-17 13:00:00
	        shelley_start_time_in_seconds=1597683600  # 2020-08-17 17:00:00
	        allegra_start_time_in_seconds=1607367600  # 2020-12-07 19:00:00
	fi

	slots_in_epoch=432000
	current_time=$(date +'%s')
	current_slot=$(( (shelley_start_time_in_seconds - byron_start_time_in_seconds)/20  + current_time - shelley_start_time_in_seconds ))
	echo $current_slot
}

network_param=$(get_network_param_value)

######################################## GET CONFIGS FOR ALL NETWORKS ########################################

db_sync_logfile="logs/db_sync_logfile.log"
db_sync_summary_logfile="logs/db_sync_summary.log"

db_sync_branch=${DB_SYNC_BRANCH}

db_sync_repo="${iohk_root_repo}/cardano-db-sync"
db_sync_latest_tag=$(get_latest_release ${db_sync_repo})

echo "We are here: ${PWD}, script name is $0"
echo ""
echo "Cloning cardano-db-sync repo and entering it ..."

git clone "git@github.com:${db_sync_repo}.git"
cd cardano-db-sync

if ! [ -z "$db_sync_branch" ]
then
      git checkout $db_sync_branch
else
      git checkout "tags/$db_sync_latest_tag"
fi

nix-build -A cardano-db-sync-extended -o db-sync-node-extended

cd config

echo ""
echo "Creating config files for each network in ${PWD}:"

mv shelley-qa-testnet.yaml shelley_qa-config.yaml
mv pgpass-shelley-qa-testnet pgpass-shelley_qa

sed -i "s/NodeConfigFile.*/NodeConfigFile: ..\/..\/cardano-node\/mainnet\/mainnet-config.json/g" mainnet-config.yaml
sed -i "s/NodeConfigFile.*/NodeConfigFile: ..\/..\/cardano-node\/shelley_qa\/shelley_qa-config.json/g" shelley_qa-config.yaml

MODIFIED_NETWORK_NAME=""
for _network in "mary_qa" "staging" "testnet"
do
	cp pgpass-mainnet "pgpass-${_network}"
    sed -i "s/mainnet/${_network}/g" "pgpass-${_network}"

	cp mainnet-config.yaml "${_network}-config.yaml"
	MODIFIED_NETWORK_NAME=$(echo "${_network}" | sed 's/_/-/') # NetworkName entry in db-sync config file requires hyphen instead of underscore
	sed -i "s/NetworkName.*/NetworkName: ${MODIFIED_NETWORK_NAME}/g" "${_network}-config.yaml"
	sed -i "s/NodeConfigFile.*/NodeConfigFile: ..\/..\/cardano-node\/${_network}\/${_network}-config.json/g" "${_network}-config.yaml"
done

cd ..

#################################### END OF: GET CONFIGS FOR ALL NETWORKS ####################################

echo "Installing postgress..."

initdb --encoding=UTF8 --locale=en_US.UTF-8 $NIX_BUILD_TOP/db-dir
pg_ctl -D $NIX_BUILD_TOP/db-dir -l logfile -o "--unix_socket_directories='/tmp'" start
PSQL_PID=$!
sleep 10
echo "Checking if PostgreSQL server was started..."
if (echo '\q' | psql -h /tmp postgres buildkite-agent); then
  echo "PostgreSQL server is verified to be started."
else
  echo "Failed to connect to local PostgreSQL server."
  exit 2
fi
ls -ltrh $NIX_BUILD_TOP
DBUSER="buildkite-agent"
DBNAME="buildkite-agent"
export PGPASSFILE=config/pgpass-${environment}
echo "/tmp:5432:$DBUSER:$DBUSER:*" > $PGPASSFILE
chmod 600 $PGPASSFILE

echo "Creating database..."

psql -h /tmp postgres buildkite-agent <<EOF
  create role "buildkite-agent" with createdb login;
  alter user "buildkite-agent" with superuser;
  create database "buildkite-agent" with owner = "buildkite-agent";
  \\connect $DBNAME
  ALTER SCHEMA public   OWNER TO "buildkite-agent";
EOF

mkdir logs

db_sync_start_time=$(echo "$(date +'%d/%m/%Y %H:%M:%S')")  # format: 17/02/2021 23:42:12

echo "Starting db-sync ..."
PGPASSFILE=config/pgpass-${environment} db-sync-node-extended/bin/cardano-db-sync-extended \
--config config/${environment}-config.yaml \
--socket-path ../cardano-node/${environment}/node.socket \
--state-dir ledger-state/${environment} \
--schema-dir schema/ >> $db_sync_logfile &

CARDANO_DB_SYNC_PID=$!
sleep 10
cat $db_sync_logfile

# End of part of the script responsible for starting db-sync

latest_node_slot=$(calculate_latest_node_slot_for_environment)
echo "latest_node_slot: $latest_node_slot"

latest_db_synced_slot=$(get_latest_db_synced_slot $db_sync_logfile)

re='^[0-9]+$'
while ! [[ $latest_db_synced_slot =~ $re ]] ; do
   echo "Not a slot number, waiting for proper log line that contains slot number..."
   sleep 20
   latest_db_synced_slot=$(get_latest_db_synced_slot $db_sync_logfile)
done

tmp_latest_db_synced_slot=$latest_db_synced_slot

# main while loop - sync db until it reaches latest node slot calculated by: calculate_latest_node_slot_for_environment

while [ $latest_db_synced_slot -lt $latest_node_slot ]
do
	sleep 20
	latest_db_synced_slot=$(get_latest_db_synced_slot $db_sync_logfile)

	if ! [[ $latest_db_synced_slot =~ $re ]] ; then
		latest_db_synced_slot=$tmp_latest_db_synced_slot
    	continue
	fi
	echo "latest_db_synced_slot: $latest_db_synced_slot"
done

db_sync_end_time=$(echo "$(date +'%d/%m/%Y %H:%M:%S')")

echo "Network: $environment" >> $db_sync_summary_logfile
echo "db_sync_start_time: $db_sync_start_time" >> $db_sync_summary_logfile
echo "db_sync_end_time: $db_sync_end_time" >> $db_sync_summary_logfile
echo "latest_db_synced_slot: $latest_db_synced_slot" >> $db_sync_summary_logfile

# Shut down node & db-sync, upload artifacts and delete node & db-sync directories

kill -9 $CARDANO_NODE_PID
kill -9 $CARDANO_DB_SYNC_PID

buildkite-agent artifact upload $db_sync_logfile
buildkite-agent artifact upload $db_sync_summary_logfile
buildkite-agent artifact upload "$cardano_node_root_dir/$node_logfile"

cd ..
rm -r cardano-node
rm -r cardano-db-sync

psql -h /tmp postgres buildkite-agent <<EOF
  DROP DATABASE "buildkite-agent";
EOF
