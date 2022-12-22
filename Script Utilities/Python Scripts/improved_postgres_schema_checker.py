import psycopg2
from assertpy import assert_that, assert_warn


def get_schema():

    try:
        conn = psycopg2.connect(
            database="preview_old", user='artur'
        )
        cursor = conn.cursor()
        # execute query and get all data
        get_all_tables = 'SELECT table_name FROM information_schema.tables WHERE table_schema=\'public\''
        cursor.execute(get_all_tables)
        tabels = cursor.fetchall();

        # Retrieving data
        db_schema = {}
        for table in tabels:
            table_name = table[0]
            get_table_fields_and_attributes = f'SELECT a.attname as "Column", pg_catalog.format_type(a.atttypid, a.atttypmod) as "Datatype" FROM pg_catalog.pg_attribute a WHERE a.attnum > 0 AND NOT a.attisdropped AND a.attrelid = ( SELECT c.oid FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relname ~ \'^{table_name}$\' AND pg_catalog.pg_table_is_visible(c.oid));'
            cursor.execute(get_table_fields_and_attributes)          
            table_with_attributes = cursor.fetchall()
            attributes = []
            table_schema = {}
            for row in table_with_attributes:
                attributes.append(row)
                table_schema.update({str(table_name) : attributes }) 
            db_schema.update({str(table_name) : attributes })
        cursor.close()
        conn.commit()
        conn.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

    return db_schema


def get_indexes():

    try:
        conn = psycopg2.connect(
            database="preview", user='artur'
        )
        cursor = conn.cursor()

        get_all_tables = f'select tbl.relname as table_name from pg_index pgi join pg_class idx on idx.oid = pgi.indexrelid join pg_namespace insp on insp.oid = idx.relnamespace join pg_class tbl on tbl.oid = pgi.indrelid join pg_namespace tnsp on tnsp.oid = tbl.relnamespace where pgi.indisunique and tnsp.nspname = \'public\';'
        cursor.execute(get_all_tables)          
        tables = cursor.fetchall()
        all_indexes = {}

        for table in tables:
            table_name =table[0]
            get_table_and_index = f'select tbl.relname as table_name, idx.relname as index_name from pg_index pgi join pg_class idx on idx.oid = pgi.indexrelid join pg_namespace insp on insp.oid = idx.relnamespace join pg_class tbl on tbl.oid = pgi.indrelid join pg_namespace tnsp on tnsp.oid = tbl.relnamespace where pgi.indisunique and tnsp.nspname = \'public\' and tbl.relname = \'{table_name}\';'
            cursor.execute(get_table_and_index)          
            table_and_index = cursor.fetchall()
            indexes = []
            table_indexes = {}
            for table, index in table_and_index:
                indexes.append(index)
                table_indexes.update({str(table_name) : indexes }) 
            all_indexes.update({str(table_name) : indexes })         
        cursor.close()
        conn.commit()
        conn.close()
        
    except (Exception, psycopg2.DatabaseError) as error:
        #print(error)
        print("error")
    finally:
        if conn is not None:
            conn.close()

    return all_indexes


def get_foreign_keys():
    QUERY='SELECT conrelid::regclass AS foreign_keys, conname AS foreign_key, pg_get_constraintdef(oid) FROM   pg_constraint WHERE  contype = 'f' AND connamespace = \'public\'::regnamespace ORDER  BY conrelid::regclass::text, contype DESC;'
    try:
        conn = psycopg2.connect(
            database="preview_old", user='artur'
        )
        cursor = conn.cursor()

        get_all_tables = f'select tbl.relname as table_name from pg_index pgi join pg_class idx on idx.oid = pgi.indexrelid join pg_namespace insp on insp.oid = idx.relnamespace join pg_class tbl on tbl.oid = pgi.indrelid join pg_namespace tnsp on tnsp.oid = tbl.relnamespace where pgi.indisunique and tnsp.nspname = \'public\';'
        cursor.execute(get_all_tables)          
        tables = cursor.fetchall()
        all_indexes = {}

        for table in tables:
            table_name =table[0]
            get_table_and_index = f'select tbl.relname as table_name, idx.relname as index_name from pg_index pgi join pg_class idx on idx.oid = pgi.indexrelid join pg_namespace insp on insp.oid = idx.relnamespace join pg_class tbl on tbl.oid = pgi.indrelid join pg_namespace tnsp on tnsp.oid = tbl.relnamespace where pgi.indisunique and tnsp.nspname = \'public\' and tbl.relname = \'{table_name}\';'
            cursor.execute(get_table_and_index)          
            table_and_index = cursor.fetchall()
            indexes = []
            table_indexes = {}
            for table, index in table_and_index:
                indexes.append(index)
                table_indexes.update({str(table_name) : indexes }) 
            all_indexes.update({str(table_name) : indexes })         
        cursor.close()
        conn.commit()
        conn.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

    return all_indexes


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

expected_indexes = {
    'pool_metadata_ref': ['pool_metadata_ref_pkey',
                          'unique_pool_metadata_ref'],
    'pool_update': ['pool_update_pkey'],
    'pool_owner': ['pool_owner_pkey'],
    'pool_retire': ['pool_retire_pkey'],
    'ada_pots': ['ada_pots_pkey'],
    'pool_relay': ['pool_relay_pkey'],
    'schema_version': ['schema_version_pkey'],
    'pool_hash': ['pool_hash_pkey', 'unique_pool_hash'],
    'slot_leader': ['slot_leader_pkey', 'unique_slot_leader'],
    'block': ['block_pkey', 'unique_block'],
    'tx': ['tx_pkey', 'unique_tx'],
    'stake_address': ['stake_address_pkey', 'unique_stake_address'],
    'tx_out': ['tx_out_pkey', 'unique_txout'],
    'datum': ['datum_pkey', 'unique_datum'],
    'redeemer': ['redeemer_pkey'],
    'tx_in': ['tx_in_pkey'],
    'collateral_tx_in': ['collateral_tx_in_pkey'],
    'meta': ['meta_pkey', 'unique_meta'],
    'epoch': ['epoch_pkey', 'unique_epoch'],
    'stake_registration': ['stake_registration_pkey'],
    'stake_deregistration': ['stake_deregistration_pkey'],
    'tx_metadata': ['tx_metadata_pkey'],
    'delegation': ['delegation_pkey'],
    'reward': ['reward_pkey', 'unique_reward'],
    'withdrawal': ['withdrawal_pkey'],
    'epoch_stake': ['epoch_stake_pkey', 'unique_stake'],
    'treasury': ['treasury_pkey'],
    'reserve': ['reserve_pkey'],
    'pot_transfer': ['pot_transfer_pkey'],
    'epoch_sync_time': ['epoch_sync_time_pkey', 'unique_epoch_sync_time'
                        ],
    'ma_tx_mint': ['ma_tx_mint_pkey'],
    'ma_tx_out': ['ma_tx_out_pkey'],
    'script': ['script_pkey', 'unique_script'],
    'cost_model': ['cost_model_pkey', 'unique_cost_model'],
    'epoch_param': ['epoch_param_pkey'],
    'pool_offline_data': ['pool_offline_data_pkey',
                          'unique_pool_offline_data'],
    'param_proposal': ['param_proposal_pkey'],
    'pool_offline_fetch_error': ['pool_offline_fetch_error_pkey',
                                 'unique_pool_offline_fetch_error'],
    'multi_asset': ['multi_asset_pkey', 'unique_multi_asset'],
    'delisted_pool': ['delisted_pool_pkey', 'unique_delisted_pool'],
    'reserved_pool_ticker': ['reserved_pool_ticker_pkey',
                             'unique_reserved_pool_ticker'],
    'extra_key_witness': ['extra_key_witness_pkey'],
    'collateral_tx_out': ['collateral_tx_out_pkey'],
    'reference_tx_in': ['reference_tx_in_pkey'],
    'redeemer_data': ['redeemer_data_pkey', 'unique_redeemer_data'],
    'reverse_index': ['reverse_index_pkey'],
    }

# For testing purposes - update expected values with wrong ones:
#expected_schema.update({"schema_version" : [('id', 'bigint'), ('stage_one', 'bigint'), ('stage_two', 'bigint'), ('stage_three', 'bigint')] })
#assert_warn(get_schema()).is_equal_to(expected_schema)

expected_indexes.update({"schema_version" : [('id', 'bigint'), ('stage_one', 'bigint'), ('stage_two', 'bigint'), ('stage_three', 'bigint')] })
#assert_that(get_indexes()).described_as('Warning: Wrong Indexes').is_equal_to(expected_indexes)

def check_database(fn, msg, expected):
    try:
        assert_that(fn()).described_as(msg).is_equal_to(expected)
    except AssertionError as e:
        #print(e)
        return e

#print(get_indexes())
get_indexes_check_result = check_database(get_indexes,'Warning: Wrong Indexes', expected_indexes)
if get_indexes_check_result:
    print(f"RESULT: {get_indexes_check_result}")