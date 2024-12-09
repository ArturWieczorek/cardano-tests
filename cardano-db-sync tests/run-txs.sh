#!/bin/bash

function usage() {
    cat << HEREDOC

    arguments:
    -n          network - possible options: allegra, launchpad, mary_qa, mainnet, staging, testnet, shelley_qa
    -e          era - DEFAULT: mary, possible options are: byron, shelley, allegra, mary

    optional arguments:
      -h, --help           show this help message and exit

Example:

./run-txs.sh -n shelley_qa

USE UNDERSCORES IN NETWORK NAMES !!!
HEREDOC
}

while getopts ":h:n:a:" o; do
    case "${o}" in
        h)
            usage
            ;;
        n)
            network=${OPTARG}
            ;;
        e)
            era=${OPTARG}
            ;;
        *)
            echo "NO SUCH ARGUMENT: ${OPTARG}"
            usage
            ;;
    esac
done
if [ $? != 0 ] || [ $# == 0 ] ; then
    echo "ERROR: Error in command line arguments." >&2 ; usage; exit 1 ;
fi
shift $((OPTIND-1))

get_tx_info_for_address () {
    local query_address=$1
    local tx=$(cardano-cli query utxo --testnet-magic ${NETWORK_MAGIC} --address $query_address --${ERA}-era | grep "^[^- ]" | sort -k 2n | tail -1)

    if [ $? != 0 ]; then
        error_msg "Error when performing query utxo on $query_address"
        exit 1
    fi

    echo $tx
}

get_input_for_tx () {
    local utxo=$1
    local id=$2
    local input="${utxo}#${id}"

    echo $input
}

get_balance_for_tx () {
    local balance=$3

    echo $balance
}

get_current_tip () {
    local tip=$(cardano-cli query tip --testnet-magic ${NETWORK_MAGIC})

    echo $tip
}

get_slot_number () {
    local tip=$(get_current_tip)
    local slot=$(echo $tip | jq .'slotNo')

    echo $slot
}

function get_network_param() {
    local requested_param=$1
    network_param=$(cat ${network}/${network}-shelley-genesis.json | grep ${requested_param} | grep -E -o "[0-9]+")
    echo $network_param

}

export CARDANO_NODE_SOCKET_PATH=${PWD}/cardano-node/${network}/node.socket
MODIFIED_NETWORK_NAME=$(echo "${network}" | sed 's/_/-/')

cd cardano-node

NETWORK_MAGIC=$(get_network_param "networkMagic")
KEY_DEPOSIT=$(get_network_param "keyDeposit")
POOL_DEPOSIT=$(get_network_param "poolDeposit")
SLOTS_PER_KES_PERIOD=$(get_network_param "slotsPerKESPeriod")
EPOCH_LENTH=$(get_network_param "epochLength")

ERA=${era:-"mary"}

#=============================  TX 1  ================================

cd keys
mkdir txs

payment_addr=$(cat payment.addr)

stake_addr=$(cat stake.addr)

extended_payment_addr=$(cat extended-payment.addr)

extended_stake_addr=$(cat stake2.addr)

txs_dir=txs

tx_details=$(get_tx_info_for_address $payment_addr)

tx_input=$(get_input_for_tx $tx_details)

tx_balance=$(get_balance_for_tx $tx_details)

amount_to_transfer=1000000

fee=200000

change=$(( $tx_balance - $amount_to_transfer - $fee))

out_sum=$(( $change +  $amount_to_transfer))

tx_number=1

simple_tx_size=287

cardano-cli transaction build-raw --${ERA}-era \
--tx-in $tx_input \
--tx-out $extended_payment_addr+$amount_to_transfer \
--tx-out $payment_addr+$change \
--fee $fee \
--out-file $txs_dir/tx${tx_number}.raw



cardano-cli transaction sign \
--tx-body-file txs/tx${tx_number}.raw \
--signing-key-file payment.skey \
--testnet-magic ${NETWORK_MAGIC} \
--out-file $txs_dir/tx${tx_number}.signed



cardano-cli transaction submit \
--tx-file txs/tx${tx_number}.signed \
--testnet-magic ${NETWORK_MAGIC}

tx_hash=$(cardano-cli transaction txid --tx-body-file $txs_dir/tx${tx_number}.raw)

echo "TX ${tx_number} Details: "
echo ""
echo "TX Hash: " $tx_hash
echo "TX Input amount before making transaction: " $tx_balance
echo "From: " $payment_addr
echo "To: " $extended_payment_addr
echo "Amount Transferred: " $amount_to_transfer
echo "Fee: " $fee
echo "Change: " $change


sleep 25


echo ""
echo "Checking DB: TX Details: "
echo ""

# Print 1 row

psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from tx where hash='\x${tx_hash}';"

get_tx_field_value () {
    local field=${1:-"*"}
    local row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select ${field} from tx where hash='\x${tx_hash}';" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
    echo $row
}


tx_id=$(get_tx_field_value "id" | awk '{ print $1}')

tx_hash_from_table=$(get_tx_field_value "hash" | awk '{ print $1}')

tx_block_id=$(get_tx_field_value "block_id" | awk '{ print $1}')

tx_block_index=$(get_tx_field_value "block_index" | awk '{ print $1}')

tx_out_sum=$(get_tx_field_value "out_sum" | awk '{ print $1}')

tx_fee=$(get_tx_field_value "fee" | awk '{ print $1}')

tx_deposit=$(get_tx_field_value "deposit" | awk '{ print $1}')

tx_size=$(get_tx_field_value "size" | awk '{ print $1}')

tx_invalid_before=$(get_tx_field_value "invalid_before" | awk '{ print $1}')

tx_invalid_hereafter=$(get_tx_field_value "invalid_hereafter" | awk '{ print $1}')


echo "tx_id: ${tx_id}"
echo "tx_hash_from_table: ${tx_hash_from_table}"
echo "tx_block_id: ${tx_block_id}"
echo "tx_block_index: ${tx_block_index}"
echo "tx_out_sum: ${tx_out_sum}"
echo "tx_fee: ${tx_fee}"
echo "tx_deposit: ${tx_deposit}"
echo "tx_size: ${tx_size}"
echo "tx_invalid_before: ${tx_invalid_before}"
echo "tx_invalid_hereafter: ${tx_invalid_hereafter}"


if [ $tx_hash_from_table != "\x${tx_hash}" ]; then
    echo "Incorrect hash. Is: $tx_hash_from_table. Should be: $tx_hash"
    exit 1
fi

if [ $tx_out_sum != $out_sum ]; then
    echo "Incorrect output sum. Is: $tx_out_sum. Should be: $out_sum"
    exit 1
fi

if [ $tx_fee != $fee ]; then
    echo "Incorrect fee. Is: $tx_fee. Should be: $fee"
    exit 1
fi

if [ $tx_deposit != 0 ]; then
    echo "Incorrect deposit. Is: $tx_deposit. Should be: 0"
    exit 1
fi

if [ $tx_size != $simple_tx_size ]; then
    echo "Incorrect tx size. Is: $tx_size. Should be: $simple_tx_size"
    exit 1
fi

if ! [ -z $tx_invalid_before ]; then
   echo "Incorrect tx_invalid_before. Is: $tx_invalid_before. Should be: <NULL>"
   exit 1
fi

if ! [ -z $tx_invalid_hereafter ]; then
    echo "Incorrect hash. Is: $tx_invalid_hereafter. Should be: <NULL>"
    exit 1
fi

echo ""
echo "Checking DB: TX Input Details: "
echo ""

# Print 1 row

psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.* from tx_out
inner join tx_in on tx_out.tx_id = tx_in.tx_out_id
inner join tx on tx.id = tx_in.tx_in_id and tx_in.tx_out_index = tx_out.index
where tx.hash = '\x${tx_hash}';"


get_tx_input_field_value () {
    local field=${1:-"*"}
    local row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.${field} from tx_out
inner join tx_in on tx_out.tx_id = tx_in.tx_out_id
inner join tx on tx.id = tx_in.tx_in_id and tx_in.tx_out_index = tx_out.index
where tx.hash = '\x${tx_hash}';" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
    echo $row
}

# Process 2 row values

tx_out_id=$(get_tx_input_field_value "id" | awk '{ print $1}'| awk '{ print $1}')

tx_out_tx_id=$(get_tx_input_field_value "tx_id" | awk '{ print $1}')

tx_out_index=$(get_tx_input_field_value "index" | awk '{ print $1}')

tx_out_address=$(get_tx_input_field_value "address" | awk '{ print $1}')

tx_out_address_raw=$(get_tx_input_field_value "address_raw" | awk '{ print $1}')

tx_out_payment_cred=$(get_tx_input_field_value "payment_cred" | awk '{ print $1}')

tx_out_stake_address_id=$(get_tx_input_field_value "stake_address_id" | awk '{ print $1}')

tx_out_value=$(get_tx_input_field_value "value" | awk '{ print $1}')


echo "tx_out_id: ${tx_out_id}"
echo "tx_out_tx_id: ${tx_out_tx_id}"
echo "tx_out_index: ${tx_out_index}"
echo "tx_out_address: ${tx_out_address}"
echo "tx_out_address_raw: ${tx_out_address_raw}"
echo "tx_out_payment_cred: ${tx_out_payment_cred}"
echo "tx_out_stake_address_id: ${tx_out_stake_address_id}"
echo "tx_out_value: ${tx_out_value}"


if [ $tx_out_address != $payment_addr ]; then
    echo "Incorrect payment_addr. Is: $tx_out_address. Should be: $payment_addr"
    exit 1
fi

if [ $tx_out_value != $tx_balance ]; then
    echo "Incorrect value. Is: $tx_out_value. Should be: $tx_balance"
    exit 1
fi


echo ""
echo "Checking DB: TX Outputs Details: "
echo ""

# Print 2 rows

psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.* from tx_out inner join tx on tx_out.tx_id = tx.id where tx.hash = '\x${tx_hash}';"

get_first_row () {
    local field=${1:-"*"}
    local first_row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.${field} from tx_out inner join tx on tx_out.tx_id = tx.id where tx.hash = '\x${tx_hash}';" | sed '$ d' | sed '$ d' | sed '$ d' |tail $n +2 |tail $n +2)
    echo $first_row
}

get_second_row () {
    local field=${1:-"*"}
    local second_row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.${field} from tx_out inner join tx on tx_out.tx_id = tx.id where tx.hash = '\x${tx_hash}';" | tail $n +2 | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
    echo $second_row
}

# Process 1 row values

tx_out_id=$(get_first_row "id" | awk '{ print $1}')

tx_out_tx_id=$(get_first_row "tx_id" | awk '{ print $1}')

tx_out_index=$(get_first_row "index" | awk '{ print $1}')

tx_out_address=$(get_first_row "address" | awk '{ print $1}')

tx_out_address_raw=$(get_first_row "address_raw" | awk '{ print $1}')

tx_out_payment_cred=$(get_first_row "payment_cred" | awk '{ print $1}')

tx_out_stake_address_id=$(get_first_row "stake_address_id" | awk '{ print $1}')

tx_out_value=$(get_first_row "value" | awk '{ print $1}')

echo ""
echo "tx_out_id: ${tx_out_id}"
echo "tx_out_tx_id: ${tx_out_tx_id}"
echo "tx_out_index: ${tx_out_index}"
echo "tx_out_address: ${tx_out_address}"
echo "tx_out_address_raw: ${tx_out_address_raw}"
echo "tx_out_payment_cred: ${tx_out_payment_cred}"
echo "tx_out_stake_address_id: ${tx_out_stake_address_id}"
echo "tx_out_value: ${tx_out_value}"
echo ""

# Assert 1 row values

if [ $tx_out_address != $payment_addr ]; then
    echo "Incorrect payment_addr. Is: $tx_out_address. Should be: $payment_addr"
    exit 1
fi

if [ $tx_out_value != $change ]; then
    echo "Incorrect value. Is: $tx_out_value. Should be: $change"
    exit 1
fi


# Process 2 row values

tx_out_id=$(get_second_row "id" | awk '{ print $1}')

tx_out_tx_id=$(get_second_row "tx_id" | awk '{ print $1}')

tx_out_index=$(get_second_row "index" | awk '{ print $1}')

tx_out_address=$(get_second_row "address" | awk '{ print $1}')

tx_out_address_raw=$(get_second_row "address_raw" | awk '{ print $1}')

tx_out_payment_cred=$(get_second_row "payment_cred" | awk '{ print $1}')

tx_out_stake_address_id=$(get_second_row "stake_address_id" | awk '{ print $1}')

tx_out_value=$(get_second_row "value" | awk '{ print $1}')

echo ""
echo "tx_out_id: ${tx_out_id}"
echo "tx_out_tx_id: ${tx_out_tx_id}"
echo "tx_out_index: ${tx_out_index}"
echo "tx_out_address: ${tx_out_address}"
echo "tx_out_address_raw: ${tx_out_address_raw}"
echo "tx_out_payment_cred: ${tx_out_payment_cred}"
echo "tx_out_stake_address_id: ${tx_out_stake_address_id}"
echo "tx_out_value: ${tx_out_value}"
echo ""

# Assert 2 row values

if [ $tx_out_address != $extended_payment_addr ]; then
    echo "Incorrect payment_addr. Is: $tx_out_address. Should be: $extended_payment_addr"
    exit 1
fi

if [ $tx_out_value != $amount_to_transfer ]; then
    echo "Incorrect value. Is: $tx_out_value. Should be: $amount_to_transfer"
    exit 1
fi

echo ""
echo "All good"

# Check if stake address for row 2 (based on id) is the same as the one associated with extended key address

echo ""
echo "Checking stake address..."

stake_address_view=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select view from stake_address where id=${tx_out_stake_address_id};" | sed '$ d' | sed '$ d' | tail $n +2 | tail $n +2)

if [ $stake_address_view != $extended_stake_addr ]; then
    echo "Incorrect value. Is: $stake_address_view. Should be: $extended_stake_addr"
    exit 1
fi

echo ""
echo "Correct value: $stake_address_view matches $extended_stake_addr"
echo ""
echo ""


#=============================  TX 2  ================================

metadata_dir=../../metadata_files

payment2_addr=$(cat payment2.addr)

stake4_addr=$(cat stake4.addr)

slot=$(get_slot_number)

lower_bound_slot=$(( $slot - 1000))

upper_bound_slot=$(( $slot + 1000))

tx_number=$((tx_number + 1))

tx_details=$(get_tx_info_for_address $payment_addr)

tx_input=$(get_input_for_tx $tx_details)

tx_balance=$(get_balance_for_tx $tx_details)

amount_to_transfer=2000000

fee=500000

change=$(( $tx_balance - $amount_to_transfer - $fee))

out_sum=$(( $change +  $amount_to_transfer))


cardano-cli transaction build-raw --${ERA}-era \
--tx-in ${tx_hash}#1 \
--tx-out $payment2_addr+$amount_to_transfer \
--tx-out $payment_addr+$change \
--invalid-before $(( $slot - 1000)) \
--invalid-hereafter $(( $slot + 1000)) \
--fee $fee \
--metadata-json-file $metadata_dir/metadata1.json \
--metadata-json-file $metadata_dir/metadata2.json \
--metadata-cbor-file $metadata_dir/metadata3.cbor \
--metadata-cbor-file $metadata_dir/metadata4.cbor \
--out-file $txs_dir/tx${tx_number}.raw


cardano-cli transaction sign \
--tx-body-file txs/tx${tx_number}.raw \
--signing-key-file payment.skey \
--testnet-magic ${NETWORK_MAGIC} \
--out-file $txs_dir/tx${tx_number}.signed


cardano-cli transaction submit \
--tx-file txs/tx${tx_number}.signed \
--testnet-magic ${NETWORK_MAGIC}

tx_hash=$(cardano-cli transaction txid --tx-body-file $txs_dir/tx${tx_number}.raw)


echo "TX ${tx_number} Details: "
echo ""
echo "TX Hash: " $tx_hash
echo "TX Input amount before making transaction: " $tx_balance
echo "From: " $payment_addr
echo "To: " $extended_payment_addr
echo "Amount Transferred: " $amount_to_transfer
echo "Fee: " $fee
echo "Change: " $change
echo "Lower Boundary Slot: " $lower_bound_slot
echo "Upper Boundary Slot: " $upper_bound_slot
echo ""

sleep 25

psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from tx where hash='\x${tx_hash}';"

tx_id=$(get_tx_field_value "id" | awk '{ print $1}')

tx_hash_from_table=$(get_tx_field_value "hash" | awk '{ print $1}')

tx_block_id=$(get_tx_field_value "block_id" | awk '{ print $1}')

tx_block_index=$(get_tx_field_value "block_index" | awk '{ print $1}')

tx_out_sum=$(get_tx_field_value "out_sum" | awk '{ print $1}')

tx_fee=$(get_tx_field_value "fee" | awk '{ print $1}')

tx_deposit=$(get_tx_field_value "deposit" | awk '{ print $1}')

tx_size=$(get_tx_field_value "size" | awk '{ print $1}')

tx_invalid_before=$(get_tx_field_value "invalid_before" | awk '{ print $1}')

tx_invalid_hereafter=$(get_tx_field_value "invalid_hereafter" | awk '{ print $1}')


echo "tx_id: ${tx_id}"
echo "tx_hash_from_table: ${tx_hash_from_table}"
echo "tx_block_id: ${tx_block_id}"
echo "tx_block_index: ${tx_block_index}"
echo "tx_out_sum: ${tx_out_sum}"
echo "tx_fee: ${tx_fee}"
echo "tx_deposit: ${tx_deposit}"
echo "tx_size: ${tx_size}"
echo "tx_invalid_before: ${tx_invalid_before}"
echo "tx_invalid_hereafter: ${tx_invalid_hereafter}"


if [ $tx_hash_from_table != "\x${tx_hash}" ]; then
    echo "Incorrect hash. Is: $tx_hash_from_table. Should be: $tx_hash"
    exit 1
fi

if [ $tx_out_sum != $out_sum ]; then
    echo "Incorrect output sum. Is: $tx_out_sum. Should be: $out_sum"
    exit 1
fi

if [ $tx_fee != $fee ]; then
    echo "Incorrect fee. Is: $tx_fee. Should be: $fee"
    exit 1
fi

if [ $tx_deposit != 0 ]; then
    echo "Incorrect deposit. Is: $tx_deposit. Should be: 0"
    exit 1
fi

if [ $tx_invalid_before != $lower_bound_slot ]; then
   echo "Incorrect tx_invalid_before. Is: $tx_invalid_before. Should be: $lower_bound_slot"
   exit 1
fi

if [ $tx_invalid_hereafter != $upper_bound_slot ]; then
    echo "Incorrect tx_invalid_hereafter. Is: $tx_invalid_hereafter. Should be: $upper_bound_slot"
    exit 1
fi


# Check Metadata:

get_metadata_for_key () {
    local key=$1
    local metadata=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select json from tx_metadata where tx_id=${tx_id} and key=${key};" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
    echo $metadata
}

echo ""
echo "Checking DB. Metadata files: "
echo ""

cat << HEREDOC

metadata1.json:

{
   "1":{
      "Name":"TX Metadata Tests",
      "Project":"Cardano-Node"
   },
   "2":{
      "Team":"QA",
      "Members":[
         "Dorin",
         "Artur",
         "Martin",
         "Edd"
      ]
   },
   "3":{
      "ComplexValue":{
         "Nested":"True"
      }
   },
   "4":[
      {
         "CI":"Buildkite"
      },
      {
         "Main_Language":"Haskell"
      }
   ]
}

metadata2.json:

{
   "5":{
      "GraphQL":"Javascript",
      "DB":"Postgress"
   },
   "6":{
      "Test":"JSON Metadata",
      "Test_No":13
   }
}

metadata3.cbor:

{
   "7":{
      "CBOR TX Metadata Test"
   },
   "8":{
      "00 01 02 03 04 05 06 07 08 09"
   }
}

metadata4.cbor:

{
   "9":{
      "CBOR TX Metadata Test 2"
   },
   "10":{
      "NestedData":{
         "Array":[
            {
               "CI":"Buildkite"
            },
            {
               "Main_Language":"Haskell"
            },
            {
               "QA":[
                  "Dorin",
                  "Artur",
                  "Martin",
                  "Edd"
               ]
            }
         ],
         "Nested":"Yes",
         "NestedValue":{
            "Nested":"True"
         }
      }
   }
}

HEREDOC

# Print Metadata

metadata_key_1_value=$(get_metadata_for_key "1")
metadata_key_2_value=$(get_metadata_for_key "2")
metadata_key_3_value=$(get_metadata_for_key "3")
metadata_key_4_value=$(get_metadata_for_key "4")
metadata_key_5_value=$(get_metadata_for_key "5")
metadata_key_6_value=$(get_metadata_for_key "6")
metadata_key_7_value=$(get_metadata_for_key "7")
metadata_key_8_value=$(get_metadata_for_key "8")
metadata_key_9_value=$(get_metadata_for_key "9")
metadata_key_10_value=$(get_metadata_for_key "10")

expected_metadata_value_1='{"Name": "TX Metadata Tests", "Project": "Cardano-Node"}'
expected_metadata_value_2='{"Team": "QA", "Members": ["Dorin", "Artur", "Martin", "Edd"]}'
expected_metadata_value_3='{"ComplexValue": {"Nested": "True"}}'
expected_metadata_value_4='[{"CI": "Buildkite"}, {"Main_Language": "Haskell"}]'
expected_metadata_value_5='{"DB": "Postgress", "GraphQL": "Javascript"}'
expected_metadata_value_6='{"Test": "JSON Metadata", "Test_No": 13}'
expected_metadata_value_7='"CBOR TX Metadata Test"'
expected_metadata_value_8='"00 01 02 03 04 05 06 07 08 09"'
expected_metadata_value_9='"CBOR TX Metadata Test 2"'
expected_metadata_value_10='{"NestedData": {"Array": [{"CI": "Buildkite"}, {"Main_Language": "Haskell"}, {"QA": ["Dorin", "Artur", "Martin", "Edd"]}], "Nested": "Yes", "NestedValue": {"Nested": "True"}}}'

if [ "$metadata_key_1_value" != "$expected_metadata_value_1" ]; then
    echo "Incorrect metadata_key_1_value. Is: $metadata_key_1_value. Should be: $expected_metadata_value_1"
    exit 1
fi

if [ "$metadata_key_2_value" != "$expected_metadata_value_2" ]; then
    echo "Incorrect metadata_key_2_value. Is: $metadata_key_2_value. Should be: $expected_metadata_value_2"
    exit 1
fi

if [ "$metadata_key_3_value" != "$expected_metadata_value_3" ]; then
    echo "Incorrect metadata_key_3_value. Is: $metadata_key_3_value. Should be: $expected_metadata_value_3"
    exit 1
fi

if [ "$metadata_key_4_value" != "$expected_metadata_value_4" ]; then
    echo "Incorrect metadata_key_4_value. Is: $metadata_key_4_value. Should be: $expected_metadata_value_4"
    exit 1
fi

if [ "$metadata_key_5_value" != "$expected_metadata_value_5" ]; then
    echo "Incorrect metadata_key_5_value. Is: $metadata_key_5_value. Should be: $expected_metadata_value_5"
    exit 1
fi

if [ "$metadata_key_6_value" != "$expected_metadata_value_6" ]; then
    echo "Incorrect metadata_key_6_value. Is: $metadata_key_6_value. Should be: $expected_metadata_value_6"
    exit 1
fi

if [ "$metadata_key_7_value" != "$expected_metadata_value_7" ]; then
    echo "Incorrect metadata_key_7_value. Is: $metadata_key_7_value. Should be: $expected_metadata_value_7"
    exit 1
fi

if [ "$metadata_key_8_value" != "$expected_metadata_value_8" ]; then
    echo "Incorrect metadata_key_8_value. Is: $metadata_key_8_value. Should be: $expected_metadata_value_8"
    exit 1
fi

if [ "$metadata_key_9_value" != "$expected_metadata_value_9" ]; then
    echo "Incorrect metadata_key_9_value. Is: $metadata_key_9_value. Should be: $expected_metadata_value_9"
    exit 1
fi

if [ "$metadata_key_10_value" != "$expected_metadata_value_10" ]; then
    echo "Incorrect metadata_key_10_value. Is: $metadata_key_10_value. Should be: $expected_metadata_value_10"
    exit 1
fi

echo ""
echo "All Good "
echo ""

echo ""
echo "Checking DB: TX Input Details: "
echo ""

# Print 1 row

psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.* from tx_out
inner join tx_in on tx_out.tx_id = tx_in.tx_out_id
inner join tx on tx.id = tx_in.tx_in_id and tx_in.tx_out_index = tx_out.index
where tx.hash = '\x${tx_hash}';"


get_tx_input_field_value () {
    local field=${1:-"*"}
    local row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.${field} from tx_out
inner join tx_in on tx_out.tx_id = tx_in.tx_out_id
inner join tx on tx.id = tx_in.tx_in_id and tx_in.tx_out_index = tx_out.index
where tx.hash = '\x${tx_hash}';" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
    echo $row
}

# Process 2 row values

tx_out_id=$(get_tx_input_field_value "id" | awk '{ print $1}'| awk '{ print $1}')

tx_out_tx_id=$(get_tx_input_field_value "tx_id" | awk '{ print $1}')

tx_out_index=$(get_tx_input_field_value "index" | awk '{ print $1}')

tx_out_address=$(get_tx_input_field_value "address" | awk '{ print $1}')

tx_out_address_raw=$(get_tx_input_field_value "address_raw" | awk '{ print $1}')

tx_out_payment_cred=$(get_tx_input_field_value "payment_cred" | awk '{ print $1}')

tx_out_stake_address_id=$(get_tx_input_field_value "stake_address_id" | awk '{ print $1}')

tx_out_value=$(get_tx_input_field_value "value" | awk '{ print $1}')


echo "tx_out_id: ${tx_out_id}"
echo "tx_out_tx_id: ${tx_out_tx_id}"
echo "tx_out_index: ${tx_out_index}"
echo "tx_out_address: ${tx_out_address}"
echo "tx_out_address_raw: ${tx_out_address_raw}"
echo "tx_out_payment_cred: ${tx_out_payment_cred}"
echo "tx_out_stake_address_id: ${tx_out_stake_address_id}"
echo "tx_out_value: ${tx_out_value}"



if [ $tx_out_address != $payment_addr ]; then
    echo "Incorrect payment_addr. Is: $tx_out_address. Should be: $payment_addr"
    exit 1
fi

if [ $tx_out_value != $tx_balance ]; then
    echo "Incorrect value. Is: $tx_out_value. Should be: $tx_balance"
    exit 1
fi



echo ""
echo "Checking DB: TX Outputs Details: "
echo ""


# Print 2 rows

psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.* from tx_out inner join tx on tx_out.tx_id = tx.id where tx.hash = '\x${tx_hash}';"

get_first_row () {
    local field=${1:-"*"}
    local first_row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.${field} from tx_out inner join tx on tx_out.tx_id = tx.id where tx.hash = '\x${tx_hash}';" | sed '$ d' | sed '$ d' | sed '$ d' |tail $n +2 |tail $n +2)
    echo $first_row
}

get_second_row () {
    local field=${1:-"*"}
    local second_row=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select tx_out.${field} from tx_out inner join tx on tx_out.tx_id = tx.id where tx.hash = '\x${tx_hash}';" | tail $n +2 | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
    echo $second_row
}

# Process 1 row values

tx_out_id=$(get_first_row "id" | awk '{ print $1}')

tx_out_tx_id=$(get_first_row "tx_id" | awk '{ print $1}')

tx_out_index=$(get_first_row "index" | awk '{ print $1}')

tx_out_address=$(get_first_row "address" | awk '{ print $1}')

tx_out_address_raw=$(get_first_row "address_raw" | awk '{ print $1}')

tx_out_payment_cred=$(get_first_row "payment_cred" | awk '{ print $1}')

tx_out_stake_address_id=$(get_first_row "stake_address_id" | awk '{ print $1}')

tx_out_value=$(get_first_row "value" | awk '{ print $1}')

echo ""
echo "tx_out_id: ${tx_out_id}"
echo "tx_out_tx_id: ${tx_out_tx_id}"
echo "tx_out_index: ${tx_out_index}"
echo "tx_out_address: ${tx_out_address}"
echo "tx_out_address_raw: ${tx_out_address_raw}"
echo "tx_out_payment_cred: ${tx_out_payment_cred}"
echo "tx_out_stake_address_id: ${tx_out_stake_address_id}"
echo "tx_out_value: ${tx_out_value}"
echo ""

# Assert 1 row values

if [ $tx_out_address != $payment_addr ]; then
    echo "Incorrect payment_addr. Is: $tx_out_address. Should be: $payment_addr"
    exit 1
fi

if [ $tx_out_value != $change ]; then
    echo "Incorrect value. Is: $tx_out_value. Should be: $change"
    exit 1
fi


# Process 2 row values

tx_out_id=$(get_second_row "id" | awk '{ print $1}')

tx_out_tx_id=$(get_second_row "tx_id" | awk '{ print $1}')

tx_out_index=$(get_second_row "index" | awk '{ print $1}')

tx_out_address=$(get_second_row "address" | awk '{ print $1}')

tx_out_address_raw=$(get_second_row "address_raw" | awk '{ print $1}')

tx_out_payment_cred=$(get_second_row "payment_cred" | awk '{ print $1}')

tx_out_stake_address_id=$(get_second_row "stake_address_id" | awk '{ print $1}')

tx_out_value=$(get_second_row "value" | awk '{ print $1}')

echo ""
echo "tx_out_id: ${tx_out_id}"
echo "tx_out_tx_id: ${tx_out_tx_id}"
echo "tx_out_index: ${tx_out_index}"
echo "tx_out_address: ${tx_out_address}"
echo "tx_out_address_raw: ${tx_out_address_raw}"
echo "tx_out_payment_cred: ${tx_out_payment_cred}"
echo "tx_out_stake_address_id: ${tx_out_stake_address_id}"
echo "tx_out_value: ${tx_out_value}"
echo ""

# Assert 2 row values

if [ $tx_out_address != $payment2_addr ]; then
    echo "Incorrect payment_addr. Is: $tx_out_address. Should be: $payment2_addr"
    exit 1
fi

if [ $tx_out_value != $amount_to_transfer ]; then
    echo "Incorrect value. Is: $tx_out_value. Should be: $amount_to_transfer"
    exit 1
fi

echo ""
echo "All good"

# Check if stake address for row 2 (based on id) is the same as the one associated with extended key address

echo ""
echo "Checking stake address..."

stake_address_view=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select view from stake_address where id=${tx_out_stake_address_id};" | sed '$ d' | sed '$ d' | tail $n +2 | tail $n +2)

if [ $stake_address_view != $stake4_addr ]; then
    echo "Incorrect value. Is: $stake_address_view. Should be: $stake4_addr"
    exit 1
fi

echo ""
echo "Correct value: $stake_address_view matches $stake4_addr"
