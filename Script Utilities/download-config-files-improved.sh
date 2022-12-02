#!/bin/bash

user=$(echo $USER)
environments=('vasil-dev' 'shelley-qa' 'preview' 'preprod' 'mainnet')

config_dir="cardano-configs"
db_sync_config_dir="db-sync-configs"

help()
{
   # Display Help
   echo
   echo "Download config files for cardano-node and cardano-db-sync."
   echo
   echo "Option 1: run just ./download-config-files.sh"
   echo 
   echo "Script will run inside the same directory it is in and perform following operations:"
   echo "   - remove old directory with configuration files named ${config_dir} (if it already exists)"
   echo "   - create fresh direcory for config files named: ${config_dir}"
   echo "   - download configuration files for cardano-node and cardano-db-sync to ${config_dir}"
   echo "   - adjust NodeConfigFile parameter for db-sync config files to point to correct node config location"
   echo "   - create pgpass files for each environment"
   echo "   - copy node configuration directories with files for each blockchain network inside ${config_dir} to cardano-node"
   echo "     - if cardano-node repository/directory does not exist this step will be skipped"
   echo "   - copy db-sync configuration files from ${db_sync_config_dir} for each blockchain network to cardano-db-sync/config"
   echo "     - if cardano-db-sync repository/directory does not exist this step will be skipped"
   echo
   echo
   echo "Option 2: parameter 'a': ./download-config-files.sh -a 'full-path-to-directory-structure-to-be-created'"
   echo
   echo
   echo "Script will run in directory passed as a full path to \"a\" parameter. If directory does not exist it will be created."
   echo "Script will perform following operations:"
   echo   
   echo "Inside 'full-path-to-directory-structure-to-be-created' directory there will be cloned following repositories:"
   echo "   1) cardano-node - https://github.com/input-output-hk/cardano-node"
   echo "   2) cardano-db-sync - https://github.com/input-output-hk/cardano-db-sync"
   echo 
   echo "Final directory structure should look like this:"
   echo
   echo "   ├full-path-to-directory-structure-to-be-created"
   echo "   ├── cardano-node"
   echo "   ├── cardano-db-sync"
   echo
   echo "Then script will perform all operation from Option 1 - as there will be cloned repositories then "
   echo "copying operation will not be skipped."
   echo
   echo
   echo "Option 3: parameter 'c': ./download-config-files.sh -c 'full-path-to-directory-where-configs-will-be-downloaded'"
   echo "Works exactly as Option 1 but user can specify directory to witch config files will be downloaded."
   echo 
   echo "Mainnet Example"
   echo 
   echo "Node can be run like that:"
   echo 
   echo "cd /full-path-to-directory-structure/cardano-node; cardano-node run --topology mainnet/topology.json --database-path mainnet/db --socket-path mainnet/node.socket --config mainnet/config.json'"
   echo
   echo "Db-Sync can be run like that:"
   echo 
   echo "cd /full-path-to-directory-structure/cardano-db-sync; PGPASSFILE=config/pgpass-mainnet scripts/postgresql-setup.sh --createdb; export DbSyncAbortOnPanic=1; PGPASSFILE=config/pgpass-mainnet cardano-db-sync --config config/mainnet-config.json --socket-path ../cardano-node/mainnet/node.socket --schema-dir schema/ --state-dir ledger-state/mainnet"

}

create_directory_structure()
{
    echo "Creating directory ${destination_dir} in ${destination_path}:"
    mkdir -p "${destination_path}"
    cd "${destination_path}"

    echo "Cloning cardano-node and cardano-db-sync into ${destination_dir}:"
    git clone "git@github.com:input-output-hk/cardano-node.git"
    git clone "git@github.com:input-output-hk/cardano-db-sync.git"
    # If cloning using SSH (above) does not work change it to HTTPS:
    # https://github.com/input-output-hk/cardano-node.git
    # https://github.com/input-output-hk/cardano-db-sync.git
}

get_cardano_configuration_files()
{
    echo "Removing old ${config_dir} directory"

    destination_path="${destination_path:=${PWD}}"
    cd "${destination_path}"
    rm -R "${config_dir}"

    echo "Creating fresh ${config_dir} and ${db_sync_config_dir} directories"
    mkdir "${config_dir}"
    cd "${config_dir}"
    mkdir "${db_sync_config_dir}"

    echo "Downloading all config files. This may take few seconds..."
    for env in ${environments[@]}; do
        mkdir "${env}"
        cd "${env}"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/config.json"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/db-sync-config.json"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/submit-api-config.json"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/topology.json"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/byron-genesis.json"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/shelley-genesis.json"
        wget --quiet "https://book.world.dev.cardano.org/environments/${env}/alonzo-genesis.json"
        cd ..

        cd "${db_sync_config_dir}"
        wget --quiet -O "${env}-config.json" "https://book.world.dev.cardano.org/environments/${env}/db-sync-config.json"
        echo "Adjusting NodeConfigFile property for ${env}-config.json"
        sed -i "s/NodeConfigFile.*/NodeConfigFile\": \"..\/..\/cardano-node\/${env}\/config.json\",/g" "${env}-config.json"
        echo "Creating pgpass-${env} file"
        echo "/var/run/postgresql:5432:${env}:*:*" > "pgpass-${env}"
        cd ..
    done

    if [ ! -d "${destination_path}/cardano-db-sync/config" ];then
        echo "There is no config inside cardano-db-sync or probably no repository in: ${destination_path}"
        echo "  SKIPPING STEP: Copying cardano-db-sync configs from ${db_sync_config_dir} to ${destination_path}/cardano-db-sync/config"
    else
        echo "Copying cardano-db-sync configs from ${db_sync_config_dir} to ${destination_path}/cardano-db-sync/config"
        cp -a ${db_sync_config_dir}/. "${destination_path}/cardano-db-sync/config"
    fi

    if [ ! -d "${destination_path}/cardano-node/" ];then
        echo "There is no cardano-node repository in: ${destination_path}"
        echo "  SKIPPING STEP: Copying cardano-node configs for ${env} to ${destination_path}/cardano-node/${env}"
    else
        for env in ${environments[@]}; do
            echo "Copying cardano-node configs for ${env} to ${destination_path}/cardano-node/${env}"
            cp -r "${env}" "${destination_path}/cardano-node/."
        done
    fi
}

while getopts ":h;a:c:" option; do
   case $option in 
      h) # display help
         help
         exit;;
      a) # create all - full directory structure, clone all repos and download configs
         a=${OPTARG}
         destination_path=${a}
         destination_dir=$(basename ${destination_path})
         create_directory_structure
         get_cardano_configuration_files
         exit;;
      c) # get only config files
         c=${OPTARG}
         destination_path=${c}
         destination_dir=$(basename ${destination_path})
         mkdir -p "${destination_path}"
         cd "${destination_path}"
         get_cardano_configuration_files
         exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done

get_cardano_configuration_files