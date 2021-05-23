#!/usr/bin/env python3

import os, sys
from pathlib import Path

# TO DO: this could be moved out of the scripts (somehow..)
dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, parent_dir_path)

from e2e_scenarios.constants import ADDRESSES_DIR_PATH, USER1_SKEY_FILE_PATH
from e2e_scenarios.utils import create_payment_key_pair_and_address, calculate_tx_fee, \
    build_raw_transaction, get_utxo_with_highest_value, sign_raw_transaction, submit_raw_transaction, calculate_tx_ttl

# Scenario
# 1. Step1: create 1 new payment addresses (addr0)
# 2. Step2: try to build, sign and send a transaction with negative fee (= -1)

print("Creating a new folder for the files created by the current test...")
tmp_directory_for_script_files = "tmp_" + sys.argv[0].split(".")[0]
Path(tmp_directory_for_script_files).mkdir(parents=True, exist_ok=True)

print(f"====== Step1: Creating 1 new payment key pair and address")
created_addresses_dict = {}
addr_name = "addr0"
addr, addr_vkey, addr_skey = create_payment_key_pair_and_address(tmp_directory_for_script_files, addr_name)
created_addresses_dict[addr_name] = [addr, addr_vkey, addr_skey]

print(f"{len(created_addresses_dict)} addresses created for the current test: {created_addresses_dict}")

print(f"====== Step2: try to build, sign and send a transaction with negative fee (= -1)")
src_address = read_address_from_file(ADDRESSES_DIR_PATH, "user1")
dst_address = created_addresses_dict.get(list(created_addresses_dict)[0])[0]
signing_key = USER1_SKEY_FILE_PATH

tx_ttl = calculate_tx_ttl()
tx_fee = -1
transferred_amount = 10

tx_build_result = build_raw_transaction(tx_ttl, tx_fee, src_address, [dst_address], [transferred_amount])
if tx_build_result[0]:
    print(f"ERROR: It should  not be possible to build a transaction with negative fee --> {tx_build_result[1]}")
    exit(2)

print(f"SUCCESS: It was not be possible to build a transaction with negative fee")
