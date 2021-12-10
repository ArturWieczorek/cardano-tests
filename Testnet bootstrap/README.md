Testnet Bootstrap
=================

Configuration
-------------

* rename the directory to e.g. `alonzo_qa_bootstrap`
* go to https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html
  and download genesis and configuration files
* replace the empty placeholder files with the downloaded files, so the file names are preserved
* make sure the `config-node1.json` points to correct names of the genesis files

Nix shell
---------

The assumption is you are running all the following commands in the DevOps nix-shell.

Faucet
------

* if you already have an address on the testnet, create a `shelley/faucet.addr` file with the address,
  and `shelley/faucet.vkey` and `shelley/faucet.skey` with the corresponding keys
* OR edit `faucet_setup.sh` file, change faucet `APIKEY`, `TESTNET_MAGIC` and `TESTNET_NAME`, and run the script

Running the node
----------------

* run the `run_node1.sh` script
* wait until the node is synced (check in another terminal window)

Running tests
-------------

* open another terminal
* cd to `cardano-node-tests` repository
* activate the python virtual environment: `. .env/bin/activate`
* let the testing framework know what cluster era the testnet is in: `export CLUSTER_ERA=alonzo` (e.g.)
* if the transaction era you want to run the tests with is different than the default one, set it: `export TX_ERA=alonzo` (e.g.)
* let the testing framework know path to the testnet bootstrap directory: `export BOOTSTRAP_DIR=$HOME/tmp/alonzo_qa_bootstrap` (e.g.)
* set the `CARDANO_NODE_SOCKET_PATH`: `export CARDANO_NODE_SOCKET_PATH=$HOME/path/to/cardano-node/state-cluster0/relay1.socket`
  IMPORTANT: the socket file can be created in whatever path you want, however it needs to end with `state-cluster0/relay1.socket`!
* (optional) set teporary directory for storing pytest artifacts: `mkdir $PWD/tmp; export TMPDIR=$PWD/tmp`
* run the tests: `make testnets`
