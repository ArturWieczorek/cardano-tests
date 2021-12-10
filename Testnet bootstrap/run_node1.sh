#!/bin/sh

SCRIPT_DIR="$(readlink -m "${0%/*}")"
export CARDANO_NODE_SOCKET_PATH="$SCRIPT_DIR/node1.socket"

exec cardano-node run --topology topology-node1.json --database-path node1-db/ --socket-path node1.socket --config config-node1.json
