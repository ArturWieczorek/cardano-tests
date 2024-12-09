#!/bin/bash

function usage() {
    cat << HEREDOC

    arguments:
    -n          network - possible options: allegra, launchpad, mary_qa, mainnet, staging, testnet, shelley_qa
    -e          era - DEFAULT: mary, possible options are: byron, shelley, allegra, mary

    optional arguments:
      -h, --help           show this help message and exit

Example:

./register-stake-addresses.sh -n shelley_qa

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

#=============================  TX 1  Register Stake 2 certificate ================================

cd keys
mkdir txs

tx_number=1

payment_addr=$(cat payment.addr)

extended_stake_addr=$(cat stake2.addr)

txs_dir=txs

tx_details=$(get_tx_info_for_address $payment_addr)

tx_input=$(get_input_for_tx $tx_details)

tx_balance=$(get_balance_for_tx $tx_details)

fee=200000

amount_to_transfer=0

change=$(( $tx_balance - $KEY_DEPOSIT - $fee))

out_sum=$(( $change + $amount_to_transfer))

tx_number=1

simple_tx_size=258


cardano-cli stake-address registration-certificate \
--stake-verification-key-file stake2.vkey \
--out-file stake2.cert


cardano-cli transaction build-raw --${ERA}-era \
--tx-in $tx_input \
--tx-out $payment_addr+$change \
--fee $fee \
--out-file $txs_dir/stake_reg_tx_${tx_number}.raw \
--certificate-file stake2.cert


cardano-cli transaction sign \
--tx-body-file $txs_dir/stake_reg_tx_${tx_number}.raw \
--signing-key-file payment.skey \
--testnet-magic ${NETWORK_MAGIC} \
--out-file $txs_dir/stake_reg_tx_${tx_number}.signed


cardano-cli transaction submit \
--tx-file $txs_dir/stake_reg_tx_${tx_number}.signed \
--testnet-magic ${NETWORK_MAGIC}


tx_hash=$(cardano-cli transaction txid --tx-body-file $txs_dir/stake_reg_tx_${tx_number}.raw)


echo "TX ${tx_number} Details: "
echo ""
echo "TX Hash: " $tx_hash
echo "TX Input amount before making transaction: " $tx_balance
echo "From: " $payment_addr
echo "Amount Transferred: " $amount_to_transfer
echo "Fee: " $fee
echo "Change: " $change


sleep 30


echo ""
echo "Checking DB: TX Details: "
echo ""

# Print 1 row


get_tx_field_value () {
    local field=${1:-"*"}
    local row=$(psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select ${field} from tx where hash='\x${tx_hash}';" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
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

if [ $tx_deposit != $KEY_DEPOSIT ]; then
    echo "Incorrect deposit. Is: $tx_deposit. Should be: $KEY_DEPOSIT"
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
echo "Tx Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from tx where hash='\x${tx_hash}';"

echo ""
echo "Stake_Registration Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}');"

echo ""
echo "Stake_Address Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from stake_address where id in (select addr_id from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}'));"


registered_stake_address=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select view from stake_address where id in (select addr_id from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}'));"| tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')


if [ $registered_stake_address != $extended_stake_addr ]; then
    echo "Incorrect registered_stake_address. Is: $registered_stake_address. Should be: $extended_stake_addr"
    exit 1
fi

echo "$registered_stake_address in DB matches $extended_stake_addr from local file."


#=============================  TX 2  Register Stake 3 certificate ================================


tx_number=$((tx_number + 1))

stake3_addr=$(cat stake3.addr)

slot=$(get_slot_number)

lower_bound_slot=$(( $slot - 1000))

tx_details=$(get_tx_info_for_address $payment_addr)

tx_input=$(get_input_for_tx $tx_details)

tx_balance=$(get_balance_for_tx $tx_details)

amount_to_transfer=0

change=$(( $tx_balance - $KEY_DEPOSIT - $fee))

out_sum=$(( $change + $amount_to_transfer))

simple_tx_size=264


cardano-cli stake-address registration-certificate \
--stake-verification-key-file stake3.vkey \
--out-file stake3.cert


cardano-cli transaction build-raw --${ERA}-era \
--tx-in $tx_input \
--tx-out $payment_addr+$change \
--fee $fee \
--invalid-before $lower_bound_slot \
--out-file $txs_dir/stake_reg_tx_${tx_number}.raw \
--certificate-file stake3.cert


cardano-cli transaction sign \
--tx-body-file $txs_dir/stake_reg_tx_${tx_number}.raw \
--signing-key-file payment.skey \
--testnet-magic ${NETWORK_MAGIC} \
--out-file $txs_dir/stake_reg_tx_${tx_number}.signed


cardano-cli transaction submit \
--tx-file $txs_dir/stake_reg_tx_${tx_number}.signed \
--testnet-magic ${NETWORK_MAGIC}


tx_hash=$(cardano-cli transaction txid --tx-body-file $txs_dir/stake_reg_tx_${tx_number}.raw)


echo ""
echo "TX ${tx_number} Details: "
echo ""
echo "TX Hash: " $tx_hash
echo "TX Input amount before making transaction: " $tx_balance
echo "From: " $payment_addr
echo "Amount Transferred: " $amount_to_transfer
echo "Fee: " $fee
echo "Change: " $change


sleep 30


echo ""
echo "Checking DB: TX Details: "
echo ""

# Print 1 row

get_tx_field_value () {
    local field=${1:-"*"}
    local row=$(psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select ${field} from tx where hash='\x${tx_hash}';" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
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

if [ $tx_deposit != $KEY_DEPOSIT ]; then
    echo "Incorrect deposit. Is: $tx_deposit. Should be: $KEY_DEPOSIT"
    exit 1
fi

if [ $tx_size != $simple_tx_size ]; then
    echo "Incorrect tx size. Is: $tx_size. Should be: $simple_tx_size"
    exit 1
fi

if [ $tx_invalid_before != $lower_bound_slot ]; then
   echo "Incorrect tx_invalid_before. Is: $tx_invalid_before. Should be: $lower_bound_slot"
   exit 1
fi

if ! [ -z $tx_invalid_hereafter ]; then
    echo "Incorrect hash. Is: $tx_invalid_hereafter. Should be: <NULL>"
    exit 1
fi

echo ""
echo "Tx Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from tx where hash='\x${tx_hash}';"

echo ""
echo "Stake_Registration Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}');"

echo ""
echo "Stake_Address Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from stake_address where id in (select addr_id from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}'));"


registered_stake_address=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select view from stake_address where id in (select addr_id from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}'));"| tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')


if [ $registered_stake_address != $stake3_addr ]; then
    echo "Incorrect registered_stake_address. Is: $registered_stake_address. Should be: $extended_stake_addr"
    exit 1
fi

echo "$registered_stake_address in DB matches $stake3_addr from local file."


#=============================  TX 3  Register Stake 4 certificate ================================


tx_number=$((tx_number + 1))

stake4_addr=$(cat stake4.addr)

slot=$(get_slot_number)

upper_bound_slot=$(( $slot + 1000))

tx_details=$(get_tx_info_for_address $payment_addr)

tx_input=$(get_input_for_tx $tx_details)

tx_balance=$(get_balance_for_tx $tx_details)

amount_to_transfer=0

change=$(( $tx_balance - $KEY_DEPOSIT - $fee))

out_sum=$(( $change + $amount_to_transfer))

simple_tx_size=264

cardano-cli stake-address registration-certificate \
--stake-verification-key-file stake4.vkey \
--out-file stake4.cert


cardano-cli transaction build-raw --${ERA}-era \
--tx-in $tx_input \
--tx-out $payment_addr+$change \
--fee $fee \
--invalid-hereafter $upper_bound_slot \
--out-file $txs_dir/stake_reg_tx_${tx_number}.raw \
--certificate-file stake4.cert


cardano-cli transaction sign \
--tx-body-file $txs_dir/stake_reg_tx_${tx_number}.raw \
--signing-key-file payment.skey \
--testnet-magic ${NETWORK_MAGIC} \
--out-file $txs_dir/stake_reg_tx_${tx_number}.signed


cardano-cli transaction submit \
--tx-file $txs_dir/stake_reg_tx_${tx_number}.signed \
--testnet-magic ${NETWORK_MAGIC}


tx_hash=$(cardano-cli transaction txid --tx-body-file $txs_dir/stake_reg_tx_${tx_number}.raw)


echo "TX ${tx_number} Details: "
echo ""
echo "TX Hash: " $tx_hash
echo "TX Input amount before making transaction: " $tx_balance
echo "From: " $payment_addr
echo "Amount Transferred: " $amount_to_transfer
echo "Fee: " $fee
echo "Change: " $change


sleep 30


echo ""
echo "Checking DB: TX Details: "
echo ""

# Print 1 row

get_tx_field_value () {
    local field=${1:-"*"}
    local row=$(psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select ${field} from tx where hash='\x${tx_hash}';" | tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')
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

if [ $tx_deposit != $KEY_DEPOSIT ]; then
    echo "Incorrect deposit. Is: $tx_deposit. Should be: $KEY_DEPOSIT"
    exit 1
fi

if [ $tx_size != $simple_tx_size ]; then
    echo "Incorrect tx size. Is: $tx_size. Should be: $simple_tx_size"
    exit 1
fi

if ! [ -z $tx_invalid_before != $lower_bound_slot ]; then
   echo "Incorrect tx_invalid_before. Is: $tx_invalid_before. Should be: <NULL>"
   exit 1
fi

if [ $tx_invalid_hereafter != $upper_bound_slot ]; then
    echo "Incorrect hash. Is: $tx_invalid_hereafter. Should be: $upper_bound_slot"
    exit 1
fi

echo ""
echo "Tx Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from tx where hash='\x${tx_hash}';"

echo ""
echo "Stake_Registration Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}');"

echo ""
echo "Stake_Address Table Details: "
echo ""

psql -P pager=off -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select * from stake_address where id in (select addr_id from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}'));"


registered_stake_address=$(psql -U postgres -d ${MODIFIED_NETWORK_NAME} -c "select view from stake_address where id in (select addr_id from stake_registration where tx_id in (select id from tx where hash='\x${tx_hash}'));"| tail $n +2 | tail $n +2 | sed '$ d' | sed '$ d')


if [ $registered_stake_address != $stake4_addr ]; then
    echo "Incorrect registered_stake_address. Is: $registered_stake_address. Should be: $stake4_addr"
    exit 1
fi

echo "$registered_stake_address in DB matches $stake4_addr from local file."


: <<'COMMENTs'
COMMENTs
