#!/usr/bin/env python3

import os, sys
from pathlib import Path

# TO DO: this could be moved out of the scripts (somehow..)
dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, parent_dir_path)

from e2e_scenarios.constants import ADDRESSES_DIR_PATH, USER1_SKEY_FILE_PATH
from e2e_scenarios.utils import create_payment_key_pair_and_address, get_current_tip, calculate_tx_fee, \
    build_raw_transaction, get_utxo_with_highest_value, sign_raw_transaction, submit_raw_transaction, \
    get_current_slot_no

# Scenario
# 1. Step1: create 1 new payment addresses (addr0)
# 2. Step2: try to build, sign and send a transaction with ttl in the past (= tip - 1) - is should not be possible

print("Creating a new folder for the files created by the current test...")
tmp_directory_for_script_files = "tmp_" + sys.argv[0].split(".")[0]
Path(tmp_directory_for_script_files).mkdir(parents=True, exist_ok=True)

print(f"====== Step1: Creating 1 new payment key pair and address")
created_addresses_dict = {}
addr_name = "addr0"
addr, addr_vkey, addr_skey = create_payment_key_pair_and_address(tmp_directory_for_script_files, addr_name)
created_addresses_dict[addr_name] = [addr, addr_vkey, addr_skey]

print(f"{len(created_addresses_dict)} addresses created for the current test: {created_addresses_dict}")

print(f"====== Step2: try to build, sign and submit a transaction with ttl in the past (= tip - 1)")
src_address = read_address_from_file(ADDRESSES_DIR_PATH, "user1")
dst_address = created_addresses_dict.get(list(created_addresses_dict)[0])[0]
transferred_amount = 1
signing_key = USER1_SKEY_FILE_PATH

current_slot_no = get_current_slot_no()
print(f"current_slot_no: {current_slot_no}")

tx_ttl = current_slot_no - 1
print(f"tx_ttl: {tx_ttl}")

tx_fee = calculate_tx_fee(src_address, [dst_address], tx_ttl)
print(f"tx_fee: {tx_fee}")

tx_build_result = build_raw_transaction(tx_ttl, tx_fee, src_address, [dst_address], [transferred_amount])
if not tx_build_result[0]:
    print(f"ERROR: It should be possible to build a transaction with ttl in the past --> {tx_build_result[1]}")
    exit(2)
tx_body_file = tx_build_result[1]

tx_sign_result = sign_raw_transaction(tx_body_file, signing_keys=[signing_key])
if not tx_sign_result[0]:
    print(f"ERROR: It should be possible to sign a transaction with ttl in the past --> {tx_sign_result[1]}")
    exit(2)
tx_signed_file = tx_sign_result[1]

tx_submit_result = submit_raw_transaction(tx_signed_file)
if tx_submit_result[0]:
    print(f"ERROR: Unexpected tx submit result for a tx with ttl in the past")
    exit(2)
if "ExpiredUTxO" not in str(tx_submit_result[1]):
    print(f"ERROR: 'ExpiredUTxO' keyword not found into the tx_submit error message")
    exit(2)

print(f"SUCCESS: It was not be possible to submit a transaction with ttl in the past")

# TO DO: To decide when a script will be considered pass/fail
