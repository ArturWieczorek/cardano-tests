#!/usr/bin/env python3

import os, sys
from pathlib import Path

# TO DO: this could be moved out of the scripts (somehow..)
dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, parent_dir_path)

from e2e_scenarios.constants import USER1_ADDRESS, USER1_SKEY_FILE_PATH
from e2e_scenarios.utils import create_payment_key_pair_and_address, create_stake_key_pair_and_address, \
    calculate_tx_ttl, calculate_tx_fee, get_address_balance, send_funds, wait_for_new_tip, assert_address_balance, \
    build_raw_transaction

# Scenario
# 1. Step1: create 1 new payment addresses (addr0) and 1 stake address (addr0_stake)
# 2. Step2: send (tx_fee + 2000) Lovelace form user1 (the faucet) to addr0
# 3. Step3: try to send 100 Lovelace from addr0 to addr0_stake

print("Creating a new folder for the files created by the current test...")
tmp_directory_for_script_files = "tmp_" + sys.argv[0].split(".")[0]
Path(tmp_directory_for_script_files).mkdir(parents=True, exist_ok=True)

print(f"====== Step1: create 1 new payment addresses (addr0) and 1 stake address (addr0_stake)")
addr_name = "addr0"
addr, addr_vkey_file, addr_skey_file = create_payment_key_pair_and_address(tmp_directory_for_script_files, addr_name)
print(f"Address successfully created - {addr}; {addr_vkey_file}; {addr_skey_file}")

stake_addr, stake_addr_vkey_file, stake_addr_skey_file = create_stake_key_pair_and_address(
    tmp_directory_for_script_files, addr_name)
print(f"Stake address successfully created - {stake_addr}; {stake_addr_vkey_file}; {stake_addr_skey_file}")

print(f"====== Step2: send some funds from user1 (the faucet) to addr0.addr")
tx_ttl = calculate_tx_ttl()
src_address = USER1_ADDRESS
dst_address = addr
tx_fee = calculate_tx_fee(src_address, dst_address, tx_ttl)
transferred_amount = int(2 * tx_fee + 2000)
signing_keys_list = [USER1_SKEY_FILE_PATH]

src_add_balance_init = get_address_balance(src_address)
dst_init_balance = get_address_balance(dst_address)

print(f"Send {transferred_amount} Lovelace from {src_address} to {dst_address}")
send_funds(src_address, tx_fee, tx_ttl,
           destinations_list=dst_address,
           transferred_amounts=transferred_amount,
           signing_keys=signing_keys_list)

wait_for_new_tip()
wait_for_new_tip()

print(f"Check that the balance for source address was correctly updated")
assert_address_balance(src_address, src_add_balance_init - tx_fee - transferred_amount)

print(f"Check that the balance for destination address was correctly updated")
assert_address_balance(dst_address, dst_init_balance + transferred_amount)

print(f"====== Step3: try to send 100 Lovelace from addr0 to addr0_stake")
tx_ttl = calculate_tx_ttl()
src_address = addr
dst_address = stake_addr
tx_fee = 0
transferred_amount = 1000

tx_build_result = build_raw_transaction(tx_ttl, tx_fee, src_address, dst_address, transferred_amount)
if tx_build_result[0]:
    print(f"ERROR: It should be possible to build a transaction using a stake address --> {tx_build_result[1]}")
    exit(2)

print(f"SUCCESS: It was not be possible to build a transaction using a stake address as destination")
