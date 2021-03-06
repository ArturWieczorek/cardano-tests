#!/usr/bin/env python3

import os, sys
from pathlib import Path

# TO DO: this could be moved out of the scripts (somehow..)
dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, parent_dir_path)

from e2e_scenarios.constants import USER1_ADDRESS, USER1_SKEY_FILE_PATH
from e2e_scenarios.utils import create_payment_key_pair_and_address, calculate_tx_fee, calculate_tx_ttl, send_funds, \
    get_address_balance, wait_for_new_tip, assert_address_balance, create_stake_key_pair_and_address, \
    create_stake_addr_registration_cert, get_key_deposit, get_pool_deposit, get_registered_stake_pools_ledger_state, \
    write_to_file, gen_pool_metadata_hash, create_stake_addr_delegation_cert, get_stake_pool_id, \
    gen_kes_key_pair, gen_vrf_key_pair, gen_cold_key_pair_and_counter, gen_pool_registration_cert, \
    get_actual_kes_period, gen_node_operational_cert, wait_for_new_epoch

# Scenario
# 1. Step1: create 1 new payment key pair and addresses (addr0.addr)
# 2. Step2: create 1 new stake key pair and addresses (addr0_stake.addr)
# 3. Step3: create 1 stake addresses registration certificate
# 4. Step4: send some funds from user1 (the faucet) to addr0.addr
# 5. Step5: create the KES key pair
# 6. Step6: create the VRF key pair
# 7. Step7: create the cold key pair and node operational certificate counter
# 8. Step8: create the node operational certificate (used when starting the pool)
# 9. Step9: create the pool metadata hash for the pool
# 10. Step10: create the stake pool registration certificate, including the pool metadata hash
# 11. Step11: crete the owner-delegation.cert in order to meet the pledge requirements
# 12. Step12: submit 3 certificates through a tx - pool registration, stake address registration, stake address delegation
# 13. Step13: check that the pool was registered on chain
# 14. Step14: check the on chain pool details
# 15. Step15: update the pool metadata values by resubmitting the pool registration certificate
# TO DO: updating the pool metadata values might cost less than pool registration (to validate this)
# 16. Step16: submit the new pool registration certificate, with the new pool metadata
# 17. Step17: wait_for_new_epoch and check that the pool metadata values were correctly updated on chain

addr_name = "owner"
node_name = "poolA"
pool_pledge = 4567
pool_cost = 3
pool_margin = 0.01

init_pool_metadata = {
    "name": "QA E2E test",
    "description": "iniatial pool description",
    "ticker": "QA1",
    "homepage": "www.test1.com"
}

updated_pool_metadata = {
    "name": "QA_test_pool",
    "description": "pool description update",
    "ticker": "QA22",
    "homepage": "www.qa22.com"
}

init_pool_metadata_url = "https://init_location.com"
updated_pool_metadata_url = "https://www.updated_location.com"

print("Creating a new folder for the files created by the current test...")
tmp_directory_for_script_files = "tmp_" + sys.argv[0].split(".")[0]
Path(tmp_directory_for_script_files).mkdir(parents=True, exist_ok=True)

print("Add the pool metadata into a different file")
init_pool_metadata_file = write_to_file(tmp_directory_for_script_files, init_pool_metadata, "init_pool_metadata.json")
updated_pool_metadata_file = write_to_file(tmp_directory_for_script_files, init_pool_metadata,
                                           "updated_pool_metadata.json")

print(f"====== Step1: create 1 new payment key pair and addresses ({addr_name}.addr)")
addr, addr_vkey_file, addr_skey_file = create_payment_key_pair_and_address(tmp_directory_for_script_files, addr_name)
print(f"Address successfully created - {addr}; {addr_vkey_file}; {addr_skey_file}")

print(f"====== Step2: create 1 new stake key pair and addresses ({addr_name}_stake.addr)")
created_stake_addresses_dict = {}
stake_addr, stake_addr_vkey_file, stake_addr_skey_file = create_stake_key_pair_and_address(
    tmp_directory_for_script_files, addr_name)
print(f"Stake address successfully created - {stake_addr}; {stake_addr_vkey_file}; {stake_addr_skey_file}")

print(f"====== Step3: create 1 stake addresses registration cert")
stake_addr_reg_cert_file = create_stake_addr_registration_cert(tmp_directory_for_script_files, stake_addr_vkey_file,
                                                               addr_name)
print(f"Stake address registration certificate created - {stake_addr_reg_cert_file}")

print(f"====== Step4: send some funds from user1 (the faucet) to {addr_name}.addr")
key_deposit = get_key_deposit()
pool_deposit = get_pool_deposit()
tx_ttl = calculate_tx_ttl()
src_address = USER1_ADDRESS
dst_addresses_list = [addr]

tx_fee = calculate_tx_fee(src_address, dst_addresses_list, tx_ttl)

transferred_amounts_list = [int(4 * tx_fee + key_deposit + pool_deposit + pool_pledge)]
signing_keys_list = [USER1_SKEY_FILE_PATH]

src_add_balance_init = get_address_balance(src_address)
dst_init_balance = get_address_balance(dst_addresses_list[0])

print(f"Send {transferred_amounts_list} Lovelace from {src_address} to {dst_addresses_list}")
send_funds(src_address, tx_fee, tx_ttl,
           destinations_list=dst_addresses_list,
           transferred_amounts=transferred_amounts_list,
           signing_keys=signing_keys_list)

wait_for_new_tip()
wait_for_new_tip()

print(f"Check that the balance for source address was correctly updated")
assert_address_balance(src_address, src_add_balance_init - tx_fee - transferred_amounts_list[0])

print(f"Check that the balance for destination address was correctly updated")
assert_address_balance(dst_addresses_list[0], dst_init_balance + transferred_amounts_list[0])

print(f"====== Step5: create the KES key pair")
node_kes_vkey_file, node_kes_skey_file = gen_kes_key_pair(tmp_directory_for_script_files, node_name)
print(f"KES keys created - {node_kes_vkey_file}; {node_kes_skey_file}")

print(f"====== Step6: create the VRF key pair")
node_vrf_vkey_file, node_vrf_skey_file = gen_vrf_key_pair(tmp_directory_for_script_files, node_name)
print(f"VRF keys created - {node_vrf_vkey_file}; {node_vrf_skey_file}")

print(f"====== Step7: create the cold key pair and node operational certificate counter")
node_cold_vkey_file, node_cold_skey_file, node_cold_counter_file = \
    gen_cold_key_pair_and_counter(tmp_directory_for_script_files, node_name)
print(f"Cold keys created and counter created - {node_cold_vkey_file}; {node_cold_skey_file}; {node_cold_counter_file}")

print(f"====== Step8: create the node operational certificate (used when starting the pool)")
kes_period = get_actual_kes_period()
node_opcert_file = gen_node_operational_cert(node_kes_vkey_file, node_cold_skey_file, node_cold_counter_file,
                                             tmp_directory_for_script_files, node_name)
print(f"Node operational certificate created - {node_opcert_file}")

print(f"====== Step9: create the pool metadata hash for the pool")
init_pool_metadata_hash = gen_pool_metadata_hash(init_pool_metadata_file)
updated_pool_metadata_hash = gen_pool_metadata_hash(updated_pool_metadata_file)

print(f"====== Step10: create the stake pool registration certificate, including the pool metadata hash")
pool_reg_cert_file = gen_pool_registration_cert(pool_pledge, pool_cost, pool_margin, node_vrf_vkey_file,
                                                node_cold_vkey_file, stake_addr_vkey_file,
                                                tmp_directory_for_script_files, node_name,
                                                pool_metadata=[init_pool_metadata_url, init_pool_metadata_hash])
print(f"Stake pool registration certificate created - {pool_reg_cert_file}")

print(f"====== Step11: crete the owner-delegation.cert in order to meet the pledge requirements")
stake_addr_delegation_cert_file = create_stake_addr_delegation_cert(tmp_directory_for_script_files,
                                                                    stake_addr_vkey_file,
                                                                    node_cold_vkey_file, addr_name)
print(f"Stake pool owner-delegation certificate created - {stake_addr_delegation_cert_file}")

print(f"====== Step12: submit 3 certificates through a tx - pool registration, stake address registration, "
      f"stake address delegation")
src_address = addr
certificates_list = [pool_reg_cert_file, stake_addr_reg_cert_file, stake_addr_delegation_cert_file]
signing_keys_list = [addr_skey_file, stake_addr_skey_file, node_cold_skey_file]

tx_ttl = calculate_tx_ttl()
tx_fee = calculate_tx_fee(src_address, [src_address], tx_ttl)

src_add_balance_init = get_address_balance(src_address)

send_funds(src_address, tx_fee + key_deposit, tx_ttl,
           certificates=certificates_list,
           signing_keys=signing_keys_list)

wait_for_new_tip()
wait_for_new_tip()

print(f"Check that the balance for source address was correctly updated")
assert_address_balance(src_address, src_add_balance_init - tx_fee)

stake_pool_id = get_stake_pool_id(node_cold_vkey_file)
print(f"====== Step13: check that the pool was registered on chain; pool id: {stake_pool_id}")
if stake_pool_id not in list(get_registered_stake_pools_ledger_state().keys()):
    print(f"ERROR: newly created stake pool id is not shown inside the available stake pools; "
          f"\n\t- Pool ID: {stake_pool_id} vs Existing IDs: {list(get_registered_stake_pools_ledger_state().keys())}")
    exit(2)
else:
    print(f"{stake_pool_id} is included into the output of ledger_state() command")

print(f"====== Step14: check the on chain pool details for pool id: {stake_pool_id}")
on_chain_stake_pool_details = get_registered_stake_pools_ledger_state().get(stake_pool_id)
on_chain_pool_details_errors_list = []
if on_chain_stake_pool_details['owners'][0] != stake_addr:
    on_chain_pool_details_errors_list.append(f"'owner' value is different than expected; "
                                             f"Expected: {stake_addr} vs "
                                             f"Returned: {on_chain_stake_pool_details['owners'][0]}")

if on_chain_stake_pool_details['cost'] != pool_cost:
    on_chain_pool_details_errors_list.append(f"'cost' value is different than expected; "
                                             f"Expected: {pool_cost} vs "
                                             f"Returned: {on_chain_stake_pool_details['cost']}")

if on_chain_stake_pool_details['margin'] != pool_margin:
    on_chain_pool_details_errors_list.append(f"'margin' value is different than expected; "
                                             f"Expected: {pool_margin} vs "
                                             f"Returned: {on_chain_stake_pool_details['margin']}")

if on_chain_stake_pool_details['pledge'] != pool_pledge:
    on_chain_pool_details_errors_list.append(f"'pledge' value is different than expected; "
                                             f"Expected: {pool_pledge} vs "
                                             f"Returned: {on_chain_stake_pool_details['pledge']}")

if on_chain_stake_pool_details['metadata'] is None:
    on_chain_pool_details_errors_list.append(f"'metadata' value is different than expected; "
                                             f"Expected: not None vs "
                                             f"Returned: {on_chain_stake_pool_details['metadata']}")

if on_chain_stake_pool_details['metadata']['hash'] is None:
    on_chain_pool_details_errors_list.append(f"'metadata hash' value is different than expected; "
                                             f"Expected: not None vs "
                                             f"Returned: {on_chain_stake_pool_details['metadata']['hash']}")

if on_chain_stake_pool_details['metadata']['url'] != init_pool_metadata_url:
    on_chain_pool_details_errors_list.append(f"'metadata url' value is different than expected; "
                                             f"Expected: {init_pool_metadata_url} vs "
                                             f"Returned: {on_chain_stake_pool_details['metadata']['url']}")

if on_chain_stake_pool_details['relays'] != []:
    on_chain_pool_details_errors_list.append(f"'relays' value is different than expected; "
                                             f"Expected: [] vs Returned: {on_chain_stake_pool_details['relays']}")

if len(on_chain_pool_details_errors_list) > 0:
    print(f"{len(on_chain_pool_details_errors_list)} pool parameter(s) have different values on chain than expected:")
    for er in on_chain_pool_details_errors_list:
        print(f"\tERROR: {er}")
        print(f"on_chain_stake_pool_details: {on_chain_stake_pool_details}")
else:
    print(f"All pool details were correctly registered on chain for {stake_pool_id} - {on_chain_stake_pool_details}")

print(f"====== Step15: update the pool metadata values by resubmitting the pool registration certificate")
new_pool_reg_cert_file = gen_pool_registration_cert(pool_pledge, pool_cost, pool_margin, node_vrf_vkey_file,
                                                    node_cold_vkey_file, stake_addr_vkey_file,
                                                    tmp_directory_for_script_files, node_name,
                                                    pool_metadata=[updated_pool_metadata_url, updated_pool_metadata_hash])
print(f"Stake pool registration certificate created - {new_pool_reg_cert_file}")

print(f"====== Step16: submit the new pool registration certificate, with the new pool metadata")
src_address = addr
certificates_list = [new_pool_reg_cert_file]
signing_keys_list = [addr_skey_file, stake_addr_skey_file, node_cold_skey_file]

tx_ttl = calculate_tx_ttl()
tx_fee = calculate_tx_fee(src_address, [src_address], tx_ttl)

src_add_balance_init = get_address_balance(src_address)

send_funds(src_address, tx_fee + key_deposit, tx_ttl,
           certificates=certificates_list,
           signing_keys=signing_keys_list)

wait_for_new_tip()
wait_for_new_tip()

print(f"Check that the balance for source address was correctly updated")
assert_address_balance(src_address, src_add_balance_init - tx_fee)

new_stake_pool_id = get_stake_pool_id(node_cold_vkey_file)

if stake_pool_id != new_stake_pool_id:
    print(f"ERROR: a new pool ID was generated after updating the pool metadata; "
          f"Initial: {stake_pool_id} vs New: {new_stake_pool_id}")
    exit(2)

print(f"====== Step17: wait_for_new_epoch and check that the pool metadata values were correctly updated on chain")
wait_for_new_epoch()
wait_for_new_tip()
on_chain_stake_pool_details_new = get_registered_stake_pools_ledger_state().get(stake_pool_id)
on_chain_pool_details_errors_list = []

if on_chain_stake_pool_details_new['owners'][0] != stake_addr:
    on_chain_pool_details_errors_list.append(f"'owner' value is different than expected; "
                                             f"Expected: {stake_addr} vs "
                                             f"Returned: {on_chain_stake_pool_details_new['owners'][0]}")

if on_chain_stake_pool_details_new['cost'] != pool_cost:
    on_chain_pool_details_errors_list.append(f"'cost' value is different than expected; "
                                             f"Expected: {pool_cost} vs "
                                             f"Returned: {on_chain_stake_pool_details_new['cost']}")

if on_chain_stake_pool_details_new['margin'] != pool_margin:
    on_chain_pool_details_errors_list.append(f"'margin' value is different than expected; "
                                             f"Expected: {pool_margin} vs "
                                             f"Returned: {on_chain_stake_pool_details_new['margin']}")

if on_chain_stake_pool_details_new['pledge'] != pool_pledge:
    on_chain_pool_details_errors_list.append(f"'pledge' value is different than expected; "
                                             f"Expected: {pool_pledge} vs "
                                             f"Returned: {on_chain_stake_pool_details_new['pledge']}")

if on_chain_stake_pool_details_new['metadata'] is None:
    on_chain_pool_details_errors_list.append(f"'metadata' value is different than expected; "
                                             f"Expected: not None vs "
                                             f"Returned: {on_chain_stake_pool_details_new['metadata']}")

if on_chain_stake_pool_details_new['metadata']['hash'] is None:
    on_chain_pool_details_errors_list.append(f"'metadata hash' value is different than expected; "
                                             f"Expected: not None vs "
                                             f"Returned: {on_chain_stake_pool_details_new['metadata']['hash']}")

if on_chain_stake_pool_details_new['metadata']['url'] != updated_pool_metadata_url:
    on_chain_pool_details_errors_list.append(f"'metadata url' value is different than expected; "
                                             f"Expected: {updated_pool_metadata_url} vs "
                                             f"Returned: {on_chain_stake_pool_details_new['metadata']['url']}")

if on_chain_stake_pool_details_new['relays'] != []:
    on_chain_pool_details_errors_list.append(f"'relays' value is different than expected; "
                                             f"Expected: [] vs Returned: {on_chain_stake_pool_details_new['relays']}")

if len(on_chain_pool_details_errors_list) > 0:
    print(f"{len(on_chain_pool_details_errors_list)} pool parameter(s) have different values on chain than expected:")
    for er in on_chain_pool_details_errors_list:
        print(f"\tERROR: {er}")
        print(f"on_chain_stake_pool_details_new: {on_chain_stake_pool_details_new}")
else:
    print(f"All pool details were correctly registered on chain for {stake_pool_id} - {on_chain_stake_pool_details_new}")
