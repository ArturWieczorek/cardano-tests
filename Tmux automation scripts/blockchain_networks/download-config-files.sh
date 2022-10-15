

environments=('vasil-dev' 'shelley-qa' 'preview' 'preprod' 'mainnet')

for env in ${environments[@]}; do
    mkdir "${env}"
    cd "${env}"
    wget "https://book.world.dev.cardano.org/environments/${env}/config.json"
    wget "https://book.world.dev.cardano.org/environments/${env}/db-sync-config.json"
    wget "https://book.world.dev.cardano.org/environments/${env}/submit-api-config.json"
    wget "https://book.world.dev.cardano.org/environments/${env}/topology.json"
    wget "https://book.world.dev.cardano.org/environments/${env}/byron-genesis.json"
    wget "https://book.world.dev.cardano.org/environments/${env}/shelley-genesis.json"
    wget "https://book.world.dev.cardano.org/environments/${env}/alonzo-genesis.json"
    cd ..
done