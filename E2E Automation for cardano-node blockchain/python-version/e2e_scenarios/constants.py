import os

CWD = os.getcwd()

TESTNET_MAGIC = "42"

TESTS_ROOT_DIR_NAME = "e2e-tests-directory"
TESTS_ROOT_DIR_PATH = os.path.join(CWD, TESTS_ROOT_DIR_NAME)

ADDRESSES_DIR_NAME = "addresses"
ADDRESSES_DIR_PATH = os.path.join(TESTS_ROOT_DIR_PATH, ADDRESSES_DIR_NAME)

POOL_1_DIR_NAME = "node-pool1"
POOL_1_DIR_PATH = os.path.join(TESTS_ROOT_DIR_PATH, POOL_1_DIR_NAME)

SOCKET_FILE_NAME = "node.sock"
NODE_SOCKET_PATH = os.path.join(POOL_1_DIR_PATH, SOCKET_FILE_NAME)

GENESIS_FILE_NAME = "genesis.json"
GENESIS_FILE_PATH = os.path.join(TESTS_ROOT_DIR_PATH, GENESIS_FILE_NAME)

PROTOCOL_PARAMS_FILENAME = "protocol-params.json"
PROTOCOL_PARAMS_FILEPATH = os.path.join(TESTS_ROOT_DIR_PATH, PROTOCOL_PARAMS_FILENAME)

USER1_SKEY_FILE_PATH = os.path.join(ADDRESSES_DIR_PATH, "user1.skey")
USER1_VKEY_FILE_PATH = os.path.join(ADDRESSES_DIR_PATH, "user1.vkey")