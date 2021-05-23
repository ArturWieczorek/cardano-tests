#!/usr/bin/env python3

import os, sys
from pathlib import Path

# TO DO: this could be moved out of the scripts (somehow..)
dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, parent_dir_path)

from e2e_scenarios.constants import USER1_ADDRESS, USER1_SKEY_FILE_PATH
from e2e_scenarios.utils import create_payment_key_pair_and_address, calculate_tx_fee, calculate_tx_ttl, \
    create_stake_key_pair_and_address, create_stake_addr_registration_cert, get_key_deposit, get_pool_deposit, \
    get_address_balance, send_funds, wait_for_new_tip, assert_address_balance, gen_kes_key_pair, gen_vrf_key_pair, \
    gen_cold_key_pair_and_counter, get_actual_kes_period, gen_node_operational_cert, gen_pool_registration_cert, \
    create_stake_addr_delegation_cert, get_stake_pool_id, get_stake_address_info, \
    get_registered_stake_pools_ledger_state

# Scenario
# 1. Step1: create 2 new payment key pairs and addresses (addr0.addr, addr1.addr)
# 2. Step2: create 2 new stake key pairs and addresses (addr0_stake.addr, addr1_stake.addr)
# 3. Step3: create 2 stake address registration certificates
# 4. Step4: send some funds from user1 (the faucet) to addr0.addr and addr1.addr
# 5. Step5: create the KES key pair
# 6. Step6: create the VRF key pair
# 7. Step7: create the cold key pair and node operational certificate counter
# 8. Step8: create the node operational certificate (used when starting the pool)
# 9. Step9: create the stake pool registration certificate (having 2 owners)
# 10. Step10: crete the 2 stake address registration certs for the pool owners, in order to meet the pledge requirements
# 11. Step11: submit the 5 certificates through a tx - pool registration, 2 x stake address registration,
#       2 x stake address delegation
# 12. Step12: check that the pool was registered on chain (having 2 owners)
# 13. Step13: check that the addr0_stake.addr and addr1_stake.addr are delegating to the pool
# 14. Step14: check the on chain pool details

node_name = "pool_multiple_owners"
pool_pledge = 100000
pool_cost = 500
pool_margin = 0.3

print("Creating a new folder for the files created by the current test...")
tmp_directory_for_script_files = "tmp_" + sys.argv[0].split(".")[0]
Path(tmp_directory_for_script_files).mkdir(parents=True, exist_ok=True)

no_of_addr_to_be_created = 2
print(f"====== Step1-3: Creating {no_of_addr_to_be_created} new payment and stake key pair(s) and address(es)")
created_addresses_dict = {}
for count in range(0, no_of_addr_to_be_created):
    addr_name = "addr" + str(count)
    addr, addr_vkey, addr_skey = create_payment_key_pair_and_address(tmp_directory_for_script_files, addr_name)
    stake_addr, stake_addr_vkey_file, stake_addr_skey_file = create_stake_key_pair_and_address(tmp_directory_for_script_files, addr_name)
    stake_addr_reg_cert_file = create_stake_addr_registration_cert(tmp_directory_for_script_files, stake_addr_vkey_file, addr_name)
    created_addresses_dict[addr_name] = [addr, addr_vkey, addr_skey, stake_addr, stake_addr_vkey_file,
                                         stake_addr_skey_file, stake_addr_reg_cert_file]

print(f" - addresses for addr0 - {created_addresses_dict.get(list(created_addresses_dict)[0])}")
print(f" - addresses for addr1 - {created_addresses_dict.get(list(created_addresses_dict)[1])}")

print(f"====== Step4: send some funds from user1 (the faucet) to the owner payment addresses")
key_deposit = get_key_deposit()
pool_deposit = get_pool_deposit()
src_address = USER1_ADDRESS
dst_addresses_list = [created_addresses_dict.get(list(created_addresses_dict)[0])[0],
                      created_addresses_dict.get(list(created_addresses_dict)[1])[0]]
tx_ttl = calculate_tx_ttl()
tx_fee = calculate_tx_fee(src_address, dst_addresses_list, tx_ttl)
transferred_amounts_list = [int(4 * tx_fee + key_deposit + pool_deposit + pool_pledge),
                            int(4 * tx_fee + key_deposit + pool_deposit + pool_pledge)]
signing_keys_list = [USER1_SKEY_FILE_PATH]

src_add_balance_init = get_address_balance(src_address)
dst_init_balances = {}
for dst_address in dst_addresses_list:
    dst_addr_balance = get_address_balance(dst_address)
    dst_init_balances[dst_address] = dst_addr_balance


print(f"Send {transferred_amounts_list} Lovelace from {src_address} to {dst_addresses_list}")
send_funds(src_address, tx_fee, tx_ttl,
           destinations_list=dst_addresses_list,
           transferred_amounts=transferred_amounts_list,
           signing_keys=signing_keys_list)

wait_for_new_tip()
wait_for_new_tip()

print(f"Check that the balance for source address was correctly updated")
assert_address_balance(src_address, src_add_balance_init - tx_fee - sum(transferred_amounts_list))

print(f"Check that the balance for destination addresses was correctly updated")
for dst_address in dst_addresses_list:
    assert_address_balance(dst_address, dst_init_balances.get(dst_address) + transferred_amounts_list[0])

print(f"====== Step5: create the KES key pair")
node_kes_vkey_file, node_kes_skey_file = gen_kes_key_pair(tmp_directory_for_script_files, node_name)
print(f"KEY keys created - {node_kes_vkey_file}; {node_kes_skey_file}")

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

print(f"====== Step9: create the stake pool registration certificate")
stake_addr_vkey_file_list = [created_addresses_dict.get(list(created_addresses_dict)[0])[4],
                             created_addresses_dict.get(list(created_addresses_dict)[1])[4]]
pool_reg_cert_file = gen_pool_registration_cert(pool_pledge, pool_cost, pool_margin, node_vrf_vkey_file,
                                                node_cold_vkey_file, stake_addr_vkey_file_list,
                                                tmp_directory_for_script_files, node_name)
print(f"Stake pool registration certificate created - {pool_reg_cert_file}")

print(f"====== Step10: crete the 2 stake address registration certs for the pool owners")
for count in range(0, no_of_addr_to_be_created):
    addr_name = "addr" + str(count)
    stake_addr_delegation_cert_file = create_stake_addr_delegation_cert(tmp_directory_for_script_files,
                                                                        created_addresses_dict.get(addr_name)[4],
                                                                        node_cold_vkey_file,
                                                                        addr_name)
    created_addresses_dict[addr_name].append(stake_addr_delegation_cert_file)
    print(f"Stake pool owner-delegation certificate created - {stake_addr_delegation_cert_file}")

print(f"====== Step11: submit the 5 certificates through a tx - pool registration, 2 x stake address registration, "
      f"2 x stake address delegation")

src_address = created_addresses_dict.get(list(created_addresses_dict)[0])[0]
certificates_list = [pool_reg_cert_file,
                     created_addresses_dict.get(list(created_addresses_dict)[0])[6],
                     created_addresses_dict.get(list(created_addresses_dict)[0])[7],
                     created_addresses_dict.get(list(created_addresses_dict)[1])[6],
                     created_addresses_dict.get(list(created_addresses_dict)[1])[7]]

signing_keys_list = [created_addresses_dict.get(list(created_addresses_dict)[0])[2],
                     created_addresses_dict.get(list(created_addresses_dict)[0])[5],
                     created_addresses_dict.get(list(created_addresses_dict)[1])[2],
                     created_addresses_dict.get(list(created_addresses_dict)[1])[5],
                     node_cold_skey_file]

tx_ttl = calculate_tx_ttl()
tx_fee = calculate_tx_fee(src_address, [src_address], tx_ttl, certificates=certificates_list)
src_add_balance_init = get_address_balance(src_address)

tx_total_fee = tx_fee + key_deposit + pool_deposit

print(f"key_deposit: {key_deposit}")
print(f"pool_deposit: {pool_deposit}")

send_funds(src_address, tx_total_fee, tx_ttl, certificates=certificates_list, signing_keys=signing_keys_list)

wait_for_new_tip()
wait_for_new_tip()

print(f"Check that the balance for source address was correctly updated")
assert_address_balance(src_address, src_add_balance_init - tx_total_fee)

stake_pool_id = get_stake_pool_id(node_cold_vkey_file)
print(f"====== Step12: check that the pool was registered on chain; pool id: {stake_pool_id}")
if stake_pool_id not in list(get_registered_stake_pools_ledger_state().keys()):
    print(f"ERROR: newly created stake pool id is not shown inside the available stake pools; "
          f"\n\t- Pool ID: {stake_pool_id} vs Existing IDs: {list(get_registered_stake_pools_ledger_state().keys())}")
    exit(2)
else:
    print(f"{stake_pool_id} is included into the output of ledger_state() command")

print(f"====== Step13: check that the addr0_stake.addr and addr1_stake.addr are delegating to the pool")
for count in range(0, no_of_addr_to_be_created):
    addr_name = "addr" + str(count)
    stake_addr = created_addresses_dict[addr_name][3]
    delegation, reward_account_balance = get_stake_address_info(stake_addr)

    if delegation != stake_pool_id:
        print(f"ERROR: delegation value for address {stake_addr} is different than expected; "
              f"Expected: {stake_pool_id} vs Returned: {delegation}")
        exit(2)
    if reward_account_balance != 0:
        print(f"ERROR: reward_account_balance value for address {stake_addr} is different than expected; "
              f"Expected: 0 vs Returned: {reward_account_balance}")
        exit(2)

print(f"====== Step14: check the on chain pool details for pool id: {stake_pool_id}")
on_chain_stake_pool_details = get_registered_stake_pools_ledger_state().get(stake_pool_id)
on_chain_pool_details_errors_list = []
if on_chain_stake_pool_details['owners'].sort() != [created_addresses_dict["addr0"][3], created_addresses_dict["addr1"][3]].sort():
    on_chain_pool_details_errors_list.append(f"'owner' value is different than expected; "
                                             f"Expected: {[created_addresses_dict['addr0'][3], created_addresses_dict['addr1'][3]]} "
                                             f"vs Returned: {on_chain_stake_pool_details['owners']}")

if on_chain_stake_pool_details['cost'] != pool_cost:
    on_chain_pool_details_errors_list.append(f"'cost' value is different than expected; "
                                             f"Expected: {pool_cost} vs Returned: {on_chain_stake_pool_details['cost']}")

if on_chain_stake_pool_details['margin'] != pool_margin:
    on_chain_pool_details_errors_list.append(f"'margin' value is different than expected; "
                                             f"Expected: {pool_margin} vs Returned: {on_chain_stake_pool_details['margin']}")

if on_chain_stake_pool_details['pledge'] != pool_pledge:
    on_chain_pool_details_errors_list.append(f"'pledge' value is different than expected; "
                                             f"Expected: {pool_pledge} vs Returned: {on_chain_stake_pool_details['pledge']}")

if on_chain_stake_pool_details['metadata'] is not None:
    on_chain_pool_details_errors_list.append(f"'metadata' value is different than expected; "
                                             f"Expected: None vs Returned: {on_chain_stake_pool_details['metadata']}")

if on_chain_stake_pool_details['relays'] != []:
    on_chain_pool_details_errors_list.append(f"'relays' value is different than expected; "
                                             f"Expected: [] vs Returned: {on_chain_stake_pool_details['relays']}")

if len(on_chain_pool_details_errors_list) > 0:
    print(f"{len(on_chain_pool_details_errors_list)} pool parameter(s) have different values on chain than expected:")
    for er in on_chain_pool_details_errors_list:
        print(f"\tERROR: {er}")
else:
    print(f"All pool details were correctly registered on chain for {stake_pool_id} - {on_chain_stake_pool_details}")
