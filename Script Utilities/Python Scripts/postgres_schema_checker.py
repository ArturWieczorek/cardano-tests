import subprocess
import sys
import os
import shlex
import time
import shutil
import csv
import psycopg2
from assertpy import assert_that



def execute_command(command):
    cmd = shlex.split(command)
    try:
        print(cmd)
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding="utf-8")
        output, errors = process.communicate(timeout=15)       
        if errors:
            print(f"Warnings or Errors: {errors}") 
        print(f"Output of command {command}: {output}") 

        exit_code = process.returncode
        if (exit_code != 0):
            print(f"Warning: Command {cmd} returned with non 0 exit code: {exit_code}")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            "command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, " ".join(str(e.output).split())
            )
        )

types = execute_command('psql -P pager=off -qt preview -c "SELECT a.attname as "Column", pg_catalog.format_type(a.atttypid, a.atttypmod) as "Datatype" FROM pg_catalog.pg_attribute a WHERE a.attnum > 0 AND NOT a.attisdropped AND a.attrelid = ( SELECT c.oid FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relname ~ \'^datum$\' AND pg_catalog.pg_table_is_visible(c.oid));"')


conn = psycopg2.connect(
   database="preview_old", user='artur'
)
cursor = conn.cursor()
# #xecute query and get all data
cursor.execute('SELECT table_name FROM information_schema.tables WHERE table_schema=\'public\'')
tabels = cursor.fetchall();

# Retrieving data
db_schema = {}
for table in tabels:
    table_name = table[0]
    cursor.execute(f'SELECT a.attname as "Column", pg_catalog.format_type(a.atttypid, a.atttypmod) as "Datatype" FROM pg_catalog.pg_attribute a WHERE a.attnum > 0 AND NOT a.attisdropped AND a.attrelid = ( SELECT c.oid FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relname ~ \'^{table_name}$\' AND pg_catalog.pg_table_is_visible(c.oid));')
    table_with_attributes = cursor.fetchall()
    attributes = []
    table_schema = {}
    for row in table_with_attributes:
        attributes.append(row)
        table_schema.update({str(table_name) : attributes }) 
    db_schema.update({str(table_name) : attributes })

#print(db_schema)
conn.close()



expected_schema = {
    'schema_version': [('id', 'bigint'), ('stage_one', 'bigint'),
                       ('stage_two', 'bigint'), ('stage_three', 'bigint'
                       )],
    'pool_update': [
        ('id', 'bigint'),
        ('hash_id', 'bigint'),
        ('cert_index', 'integer'),
        ('vrf_key_hash', 'hash32type'),
        ('pledge', 'lovelace'),
        ('active_epoch_no', 'bigint'),
        ('meta_id', 'bigint'),
        ('margin', 'double precision'),
        ('fixed_cost', 'lovelace'),
        ('registered_tx_id', 'bigint'),
        ('reward_addr_id', 'bigint'),
        ],
    'pool_owner': [('id', 'bigint'), ('addr_id', 'bigint'),
                   ('pool_update_id', 'bigint')],
    'pool_metadata_ref': [('id', 'bigint'), ('pool_id', 'bigint'),
                          ('url', 'character varying'), ('hash',
                          'hash32type'), ('registered_tx_id', 'bigint'
                          )],
    'ada_pots': [
        ('id', 'bigint'),
        ('slot_no', 'word63type'),
        ('epoch_no', 'word31type'),
        ('treasury', 'lovelace'),
        ('reserves', 'lovelace'),
        ('rewards', 'lovelace'),
        ('utxo', 'lovelace'),
        ('deposits', 'lovelace'),
        ('fees', 'lovelace'),
        ('block_id', 'bigint'),
        ],
    'pool_retire': [('id', 'bigint'), ('hash_id', 'bigint'),
                    ('cert_index', 'integer'), ('announced_tx_id',
                    'bigint'), ('retiring_epoch', 'word31type')],
    'pool_hash': [('id', 'bigint'), ('hash_raw', 'hash28type'), ('view'
                  , 'character varying')],
    'slot_leader': [('id', 'bigint'), ('hash', 'hash28type'),
                    ('pool_hash_id', 'bigint'), ('description',
                    'character varying')],
    'block': [
        ('id', 'bigint'),
        ('hash', 'hash32type'),
        ('epoch_no', 'word31type'),
        ('slot_no', 'word63type'),
        ('epoch_slot_no', 'word31type'),
        ('block_no', 'word31type'),
        ('previous_id', 'bigint'),
        ('slot_leader_id', 'bigint'),
        ('size', 'word31type'),
        ('time', 'timestamp without time zone'),
        ('tx_count', 'bigint'),
        ('proto_major', 'word31type'),
        ('proto_minor', 'word31type'),
        ('vrf_key', 'character varying'),
        ('op_cert', 'hash32type'),
        ('op_cert_counter', 'word63type'),
        ],
    'tx': [
        ('id', 'bigint'),
        ('hash', 'hash32type'),
        ('block_id', 'bigint'),
        ('block_index', 'word31type'),
        ('out_sum', 'lovelace'),
        ('fee', 'lovelace'),
        ('deposit', 'bigint'),
        ('size', 'word31type'),
        ('invalid_before', 'word64type'),
        ('invalid_hereafter', 'word64type'),
        ('valid_contract', 'boolean'),
        ('script_size', 'word31type'),
        ],
    'stake_address': [('id', 'bigint'), ('hash_raw', 'addr29type'),
                      ('view', 'character varying'), ('script_hash',
                      'hash28type')],
    'redeemer': [
        ('id', 'bigint'),
        ('tx_id', 'bigint'),
        ('unit_mem', 'word63type'),
        ('unit_steps', 'word63type'),
        ('fee', 'lovelace'),
        ('purpose', 'scriptpurposetype'),
        ('index', 'word31type'),
        ('script_hash', 'hash28type'),
        ('redeemer_data_id', 'bigint'),
        ],
    'tx_out': [
        ('id', 'bigint'),
        ('tx_id', 'bigint'),
        ('index', 'txindex'),
        ('address', 'character varying'),
        ('address_raw', 'bytea'),
        ('address_has_script', 'boolean'),
        ('payment_cred', 'hash28type'),
        ('stake_address_id', 'bigint'),
        ('value', 'lovelace'),
        ('data_hash', 'hash32type'),
        ('inline_datum_id', 'bigint'),
        ('reference_script_id', 'bigint'),
        ],
    'datum': [('id', 'bigint'), ('hash', 'hash32type'), ('tx_id',
              'bigint'), ('value', 'jsonb'), ('bytes', 'bytea')],
    'tx_in': [('id', 'bigint'), ('tx_in_id', 'bigint'), ('tx_out_id',
              'bigint'), ('tx_out_index', 'txindex'), ('redeemer_id',
              'bigint')],
    'collateral_tx_in': [('id', 'bigint'), ('tx_in_id', 'bigint'),
                         ('tx_out_id', 'bigint'), ('tx_out_index',
                         'txindex')],
    'epoch': [
        ('id', 'bigint'),
        ('out_sum', 'word128type'),
        ('fees', 'lovelace'),
        ('tx_count', 'word31type'),
        ('blk_count', 'word31type'),
        ('no', 'word31type'),
        ('start_time', 'timestamp without time zone'),
        ('end_time', 'timestamp without time zone'),
        ],
    'pool_relay': [
        ('id', 'bigint'),
        ('update_id', 'bigint'),
        ('ipv4', 'character varying'),
        ('ipv6', 'character varying'),
        ('dns_name', 'character varying'),
        ('dns_srv_name', 'character varying'),
        ('port', 'integer'),
        ],
    'stake_registration': [('id', 'bigint'), ('addr_id', 'bigint'),
                           ('cert_index', 'integer'), ('epoch_no',
                           'word31type'), ('tx_id', 'bigint')],
    'stake_deregistration': [
        ('id', 'bigint'),
        ('addr_id', 'bigint'),
        ('cert_index', 'integer'),
        ('epoch_no', 'word31type'),
        ('tx_id', 'bigint'),
        ('redeemer_id', 'bigint'),
        ],
    'delegation': [
        ('id', 'bigint'),
        ('addr_id', 'bigint'),
        ('cert_index', 'integer'),
        ('pool_hash_id', 'bigint'),
        ('active_epoch_no', 'bigint'),
        ('tx_id', 'bigint'),
        ('slot_no', 'word63type'),
        ('redeemer_id', 'bigint'),
        ],
    'tx_metadata': [('id', 'bigint'), ('key', 'word64type'), ('json',
                    'jsonb'), ('bytes', 'bytea'), ('tx_id', 'bigint')],
    'reward': [
        ('id', 'bigint'),
        ('addr_id', 'bigint'),
        ('type', 'rewardtype'),
        ('amount', 'lovelace'),
        ('earned_epoch', 'bigint'),
        ('spendable_epoch', 'bigint'),
        ('pool_id', 'bigint'),
        ],
    'withdrawal': [('id', 'bigint'), ('addr_id', 'bigint'), ('amount',
                   'lovelace'), ('redeemer_id', 'bigint'), ('tx_id',
                   'bigint')],
    'epoch_stake': [('id', 'bigint'), ('addr_id', 'bigint'), ('pool_id'
                    , 'bigint'), ('amount', 'lovelace'), ('epoch_no',
                    'word31type')],
    'ma_tx_mint': [('id', 'bigint'), ('quantity', 'int65type'), ('tx_id'
                   , 'bigint'), ('ident', 'bigint')],
    'treasury': [('id', 'bigint'), ('addr_id', 'bigint'), ('cert_index'
                 , 'integer'), ('amount', 'int65type'), ('tx_id',
                 'bigint')],
    'reserve': [('id', 'bigint'), ('addr_id', 'bigint'), ('cert_index',
                'integer'), ('amount', 'int65type'), ('tx_id', 'bigint'
                )],
    'pot_transfer': [('id', 'bigint'), ('cert_index', 'integer'),
                     ('treasury', 'int65type'), ('reserves', 'int65type'
                     ), ('tx_id', 'bigint')],
    'epoch_sync_time': [('id', 'bigint'), ('no', 'bigint'), ('seconds',
                        'word63type'), ('state', 'syncstatetype')],
    'ma_tx_out': [('id', 'bigint'), ('quantity', 'word64type'),
                  ('tx_out_id', 'bigint'), ('ident', 'bigint')],
    'script': [
        ('id', 'bigint'),
        ('tx_id', 'bigint'),
        ('hash', 'hash28type'),
        ('type', 'scripttype'),
        ('json', 'jsonb'),
        ('bytes', 'bytea'),
        ('serialised_size', 'word31type'),
        ],
    'pool_offline_data': [
        ('id', 'bigint'),
        ('pool_id', 'bigint'),
        ('ticker_name', 'character varying'),
        ('hash', 'hash32type'),
        ('json', 'jsonb'),
        ('bytes', 'bytea'),
        ('pmr_id', 'bigint'),
        ],
    'cost_model': [('id', 'bigint'), ('costs', 'jsonb'), ('hash',
                   'hash32type')],
    'param_proposal': [
        ('id', 'bigint'),
        ('epoch_no', 'word31type'),
        ('key', 'hash28type'),
        ('min_fee_a', 'word64type'),
        ('min_fee_b', 'word64type'),
        ('max_block_size', 'word64type'),
        ('max_tx_size', 'word64type'),
        ('max_bh_size', 'word64type'),
        ('key_deposit', 'lovelace'),
        ('pool_deposit', 'lovelace'),
        ('max_epoch', 'word64type'),
        ('optimal_pool_count', 'word64type'),
        ('influence', 'double precision'),
        ('monetary_expand_rate', 'double precision'),
        ('treasury_growth_rate', 'double precision'),
        ('decentralisation', 'double precision'),
        ('entropy', 'hash32type'),
        ('protocol_major', 'word31type'),
        ('protocol_minor', 'word31type'),
        ('min_utxo_value', 'lovelace'),
        ('min_pool_cost', 'lovelace'),
        ('cost_model_id', 'bigint'),
        ('price_mem', 'double precision'),
        ('price_step', 'double precision'),
        ('max_tx_ex_mem', 'word64type'),
        ('max_tx_ex_steps', 'word64type'),
        ('max_block_ex_mem', 'word64type'),
        ('max_block_ex_steps', 'word64type'),
        ('max_val_size', 'word64type'),
        ('collateral_percent', 'word31type'),
        ('max_collateral_inputs', 'word31type'),
        ('registered_tx_id', 'bigint'),
        ('coins_per_utxo_size', 'lovelace'),
        ],
    'epoch_param': [
        ('id', 'bigint'),
        ('epoch_no', 'word31type'),
        ('min_fee_a', 'word31type'),
        ('min_fee_b', 'word31type'),
        ('max_block_size', 'word31type'),
        ('max_tx_size', 'word31type'),
        ('max_bh_size', 'word31type'),
        ('key_deposit', 'lovelace'),
        ('pool_deposit', 'lovelace'),
        ('max_epoch', 'word31type'),
        ('optimal_pool_count', 'word31type'),
        ('influence', 'double precision'),
        ('monetary_expand_rate', 'double precision'),
        ('treasury_growth_rate', 'double precision'),
        ('decentralisation', 'double precision'),
        ('protocol_major', 'word31type'),
        ('protocol_minor', 'word31type'),
        ('min_utxo_value', 'lovelace'),
        ('min_pool_cost', 'lovelace'),
        ('nonce', 'hash32type'),
        ('cost_model_id', 'bigint'),
        ('price_mem', 'double precision'),
        ('price_step', 'double precision'),
        ('max_tx_ex_mem', 'word64type'),
        ('max_tx_ex_steps', 'word64type'),
        ('max_block_ex_mem', 'word64type'),
        ('max_block_ex_steps', 'word64type'),
        ('max_val_size', 'word64type'),
        ('collateral_percent', 'word31type'),
        ('max_collateral_inputs', 'word31type'),
        ('block_id', 'bigint'),
        ('extra_entropy', 'hash32type'),
        ('coins_per_utxo_size', 'lovelace'),
        ],
    'pool_offline_fetch_error': [
        ('id', 'bigint'),
        ('pool_id', 'bigint'),
        ('fetch_time', 'timestamp without time zone'),
        ('pmr_id', 'bigint'),
        ('fetch_error', 'character varying'),
        ('retry_count', 'word31type'),
        ],
    'multi_asset': [('id', 'bigint'), ('policy', 'hash28type'), ('name'
                    , 'asset32type'), ('fingerprint',
                    'character varying')],
    'meta': [('id', 'bigint'), ('start_time',
             'timestamp without time zone'), ('network_name',
             'character varying'), ('version', 'character varying')],
    'delisted_pool': [('id', 'bigint'), ('hash_raw', 'hash28type')],
    'reserved_pool_ticker': [('id', 'bigint'), ('name',
                             'character varying'), ('pool_hash',
                             'hash28type')],
    'extra_key_witness': [('id', 'bigint'), ('hash', 'hash28type'),
                          ('tx_id', 'bigint')],
    'reference_tx_in': [('id', 'bigint'), ('tx_in_id', 'bigint'),
                        ('tx_out_id', 'bigint'), ('tx_out_index',
                        'txindex')],
    'redeemer_data': [('id', 'bigint'), ('hash', 'hash32type'), ('tx_id'
                      , 'bigint'), ('value', 'jsonb'), ('bytes', 'bytea'
                      )],
    'collateral_tx_out': [
        ('id', 'bigint'),
        ('tx_id', 'bigint'),
        ('index', 'txindex'),
        ('address', 'character varying'),
        ('address_raw', 'bytea'),
        ('address_has_script', 'boolean'),
        ('payment_cred', 'hash28type'),
        ('stake_address_id', 'bigint'),
        ('value', 'lovelace'),
        ('data_hash', 'hash32type'),
        ('multi_assets_descr', 'character varying'),
        ('inline_datum_id', 'bigint'),
        ('reference_script_id', 'bigint'),
        ],
    'reverse_index': [('id', 'bigint'), ('block_id', 'bigint'),
                      ('min_ids', 'character varying')],
    'utxo_byron_view': [
        ('id', 'bigint'),
        ('tx_id', 'bigint'),
        ('index', 'txindex'),
        ('address', 'character varying'),
        ('address_raw', 'bytea'),
        ('address_has_script', 'boolean'),
        ('payment_cred', 'hash28type'),
        ('stake_address_id', 'bigint'),
        ('value', 'lovelace'),
        ('data_hash', 'hash32type'),
        ('inline_datum_id', 'bigint'),
        ('reference_script_id', 'bigint'),
        ],
    'utxo_view': [
        ('id', 'bigint'),
        ('tx_id', 'bigint'),
        ('index', 'txindex'),
        ('address', 'character varying'),
        ('address_raw', 'bytea'),
        ('address_has_script', 'boolean'),
        ('payment_cred', 'hash28type'),
        ('stake_address_id', 'bigint'),
        ('value', 'lovelace'),
        ('data_hash', 'hash32type'),
        ('inline_datum_id', 'bigint'),
        ('reference_script_id', 'bigint'),
        ],
    }

db_schema.update({"schema_version" : [('id', 'bigint'), ('stage_one', 'bigint'), ('stage_two', 'bigint'), ('stage_three', 'bigint')] })
assert_that(db_schema).is_equal_to(expected_schema)

