Start Node:

Get fresh sanchonet config files:

PREVIEW:

wget https://book.play.dev.cardano.org/environments/preview/config.json \
  https://book.play.dev.cardano.org/environments/preview/db-sync-config.json \
  https://book.play.dev.cardano.org/environments/preview/submit-api-config.json \
  https://book.play.dev.cardano.org/environments/preview/topology.json \
  https://book.play.dev.cardano.org/environments/preview/byron-genesis.json \
  https://book.play.dev.cardano.org/environments/preview/shelley-genesis.json \
  https://book.play.dev.cardano.org/environments/preview/alonzo-genesis.json \
  https://book.play.dev.cardano.org/environments/preview/conway-genesis.json


PREPROD:

wget https://book.play.dev.cardano.org/environments/preprod/config.json \
  https://book.play.dev.cardano.org/environments/preprod/db-sync-config.json \
  https://book.play.dev.cardano.org/environments/preprod/submit-api-config.json \
  https://book.play.dev.cardano.org/environments/preprod/topology.json \
  https://book.play.dev.cardano.org/environments/preprod/byron-genesis.json \
  https://book.play.dev.cardano.org/environments/preprod/shelley-genesis.json \
  https://book.play.dev.cardano.org/environments/preprod/alonzo-genesis.json \
  https://book.play.dev.cardano.org/environments/preprod/conway-genesis.json

SNACHO:

wget https://book.play.dev.cardano.org/environments/sanchonet/config.json \
  https://book.play.dev.cardano.org/environments/sanchonet/db-sync-config.json \
  https://book.play.dev.cardano.org/environments/sanchonet/submit-api-config.json \
  https://book.play.dev.cardano.org/environments/sanchonet/topology.json \
  https://book.play.dev.cardano.org/environments/sanchonet/byron-genesis.json \
  https://book.play.dev.cardano.org/environments/sanchonet/shelley-genesis.json \
  https://book.play.dev.cardano.org/environments/sanchonet/alonzo-genesis.json \
  https://book.play.dev.cardano.org/environments/sanchonet/conway-genesis.json


MAINNET:

wget https://book.play.dev.cardano.org/environments/mainnet/config.json \
  https://book.play.dev.cardano.org/environments/mainnet/db-sync-config.json \
  https://book.play.dev.cardano.org/environments/mainnet/submit-api-config.json \
  https://book.play.dev.cardano.org/environments/mainnet/topology.json \
  https://book.play.dev.cardano.org/environments/mainnet/byron-genesis.json \
  https://book.play.dev.cardano.org/environments/mainnet/shelley-genesis.json \
  https://book.play.dev.cardano.org/environments/mainnet/alonzo-genesis.json \
  https://book.play.dev.cardano.org/environments/mainnet/conway-genesis.json


Query node tip inside docker cntainer:
./bin/cardano-cli query tip --socket-path node-ipc/node.socket --mainet


./cardano-node version
cardano-node 8.6.0 - linux-x86_64 - ghc-8.10
git rev 735e6c97740c8def5d6e462bf5a29cbe6d323cfe


preview:

./cardano-node run --topology preview/topology.json \
--database-path preview/db \
--socket-path preview/node.socket \
--config preview/config.json


preprod:

./cardano-node run --topology preprod/topology.json \
--database-path preprod/db \
--socket-path preprod/node.socket \
--config preprod/config.json

sancho:

./cardano-node run --topology sancho/topology.json \
--database-path sancho/db \
--socket-path sancho/node.socket \
--config sancho/config.json


mainnet:

./cardano-node run --topology mainnet/topology.json \
--database-path mainnet/db \
--socket-path mainnet/node.socket \
--config mainnet/config.json


Start db-sync:


./db-sync-node/bin/cardano-db-sync version
cardano-db-sync 13.1.1.3 - linux-x86_64 - ghc-8.10
git revision ffde876ad45ffacf644b985c8843a46596a28e77


export DbSyncAbortOnPanic=1; 

PREVIEW:

/var/run/postgresql:5432:preview_sancho_4_1_0:*:*

  "NetworkName": "preview",
  "NodeConfigFile": "../../preview/config.json",

PGPASSFILE=config/pgpass-preview scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-preview db-sync-node/bin/cardano-db-sync --config config/preview-config.json \
--socket-path ../preview/node.socket \
--schema-dir schema/ \
--state-dir ledger-state/preview


PREPROD:

/var/run/postgresql:5432:preprod_sancho_4_1_0:*:*

  "NetworkName": "preprod",
  "NodeConfigFile": "../../preprod/config.json",

PGPASSFILE=config/pgpass-preprod scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-preprod db-sync-node/bin/cardano-db-sync --config config/preprod-config.json \
--socket-path ../preprod/node.socket \
--schema-dir schema/ \
--state-dir ledger-state/preprod


SANCHO:

/var/run/postgresql:5432:sanchonet_sancho_4_1_0:*:*

  "NetworkName": "sanchonet",
  "NodeConfigFile": "../../sancho/config.json",

PGPASSFILE=config/pgpass-sancho scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-sancho db-sync-node/bin/cardano-db-sync --config config/sancho-config.json \
--socket-path ../sancho/node.socket \
--schema-dir schema/ \
--state-dir ledger-state/sancho

export CARDANO_NODE_SOCKET_PATH=sancho/node.socket


MAINNET:

/var/run/postgresql:5432:mainnet_sancho_4_1_0:*:*

  "NetworkName": "mainnet",
  "NodeConfigFile": "../../mainnet/config.json",

PGPASSFILE=config/pgpass-mainnet scripts/postgresql-setup.sh --createdb

PGPASSFILE=config/pgpass-mainnet db-sync-node/bin/cardano-db-sync --config config/mainnet-config.yaml \
--socket-path ../mainnet/node.socket \
--schema-dir schema/ \
--state-dir ledger-state/mainnet


Generate payment keys:

./cardano-cli address key-gen \
--verification-key-file payment.vkey \
--signing-key-file payment.skey

Generate stake keys:

./cardano-cli stake-address key-gen \
--verification-key-file stake.vkey \
--signing-key-file stake.skey


Build your address:

./cardano-cli address build \
--payment-verification-key-file payment.vkey \
--stake-verification-key-file stake.vkey \
--out-file payment.addr \
--testnet-magic 4

cat payment.addr 
addr_test1qrtlplvlwgauvsljrgesrfg5lqgszk2wluk4tl3m57cj4y5nz9fjn8ww98cct76q79g05qjtyf850gpfhx2qxdvt2kpqxdu62q


Faucet:

{
  "amount": {
    "lovelace": 10000200000
  },
  "txid": "87e1943c1486d6620da7de1ee8ddc78808af6f3360a9d65590ab72c7bbed8f3d",
  "txin": "00e138bfc20c46b50cc1c9bb2d40e1b15e9891a1e9d07f86e02a8fc3647a31f1#83"
}



./cardano-cli address key-hash --payment-verification-key-file payment.vkey 
d7f0fd9f723bc643f21a3301a514f81101594eff2d55fe3ba7b12a92


export CARDANO_NODE_SOCKET_PATH=sancho/node.socket


WAITING FOR NODE TO SYNC TO TIP 100%

./cardano-cli query tip --testnet-magic 4
{
    "block": 614359,
    "epoch": 142,
    "era": "Conway",
    "hash": "7aea45a6fb75d37a439e79da8b2716c3d167b5687fa3149f72e9849cfdd4c38b",
    "slot": 12317109,
    "slotInEpoch": 48309,
    "slotsToEpochEnd": 38091,
    "syncProgress": "100.00"
}





./cardano-cli query utxo --address $(cat payment.addr) --socket-path sancho/node.socket  --testnet-magic 4
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
87e1943c1486d6620da7de1ee8ddc78808af6f3360a9d65590ab72c7bbed8f3d     0        10000000000 lovelace + TxOutDatumNone

cat payment.addr | cardano-address address inspect
{
    "stake_reference": "by value",
    "stake_key_hash_bech32": "stake_vkh1jvg4x2vaec5lrp0mgrc4p7szfv3y73aq9xuegqe43d2cy2fkm2w",
    "stake_key_hash": "931153299dce29f185fb40f150fa024b224f47a029b99403358b5582",
    "spending_key_hash_bech32": "addr_vkh16lc0m8mj80ry8us6xvq6298czyq4jnhl942luwa8ky4fyh5kdt3",
    "address_style": "Shelley",
    "spending_key_hash": "d7f0fd9f723bc643f21a3301a514f81101594eff2d55fe3ba7b12a92",
    "network_tag": 0,
    "address_type": 0
}


sancho_2_2_0=# select * from stake_address where hash_raw = '\xe0931153299dce29f185fb40f150fa024b224f47a029b99403358b5582';
  id  |                           hash_raw                           |                               view                               | script_hash 
------+--------------------------------------------------------------+------------------------------------------------------------------+-------------
 1106 | \xe0931153299dce29f185fb40f150fa024b224f47a029b99403358b5582 | stake_test1uzf3z5efnh8znuv9ldq0z586qf9jyn685q5mn9qrxk94tqsvalmq8 | 
(1 row)



Query deposit values through query protocol-parameters:

./cardano-cli query protocol-parameters --testnet-magic 4 | grep -i deposit
    "stakeAddressDeposit": 2000000,
    "stakePoolDeposit": 500000000,



ADDRESS 2:


cat payment2.addr
addr_test1qzm37vpp3mfvf92e3f9f8up5a0dx8xctn9w2qnhf93vu8whxrjth86wsfrz9szcq5cc8he6fn87mjzrnxk4qp2dk3kuqdyxp4d


cat payment2.addr | cardano-address address inspect
{
    "stake_reference": "by value",
    "stake_key_hash_bech32": "stake_vkh1ucwfwulf6pyvgkqtqznrq7l8fxvlmwggwv665q9fk6xms56vm0z",
    "stake_key_hash": "e61c9773e9d048c4580b00a6307be74999fdb9087335aa00a9b68db8",
    "spending_key_hash_bech32": "addr_vkh1ku0nqgvw6tzf2kv2f2flqd8tmf3ekzuetjsya6fvt8pm5eg67dy",
    "address_style": "Shelley",
    "spending_key_hash": "b71f30218ed2c495598a4a93f034ebda639b0b995ca04ee92c59c3ba",
    "network_tag": 0,
    "address_type": 0
}


sancho_2_2_0=# select * from stake_address where hash_raw = '\xe0e61c9773e9d048c4580b00a6307be74999fdb9087335aa00a9b68db8';
  id  |                           hash_raw                           |                               view                               | script_hash 
------+--------------------------------------------------------------+------------------------------------------------------------------+-------------
 1107 | \xe0e61c9773e9d048c4580b00a6307be74999fdb9087335aa00a9b68db8 | stake_test1urnpe9mna8gy33zcpvq2vvrmuayenldeppent2sq4xmgmwq4u9un0 | 
(1 row)



./cardano-cli query utxo --address $(cat payment2.addr) --testnet-magic 4
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
4133d06e497cb3b9a1f5c03818d660bdbeacc34dc3b88d9ca7f0a7e111200ff3     0        9997828471 lovelace + TxOutDatumNone


ADDRESS 3:

cat payment3.addr
addr_test1qq3hue3gj72k0jg28nfhegccvmaa0t0me6kp7dt7flt5c670zkdrzdu08lrkyj8fu70vm5h2anvqhfd3vn025fl8e99qwq3s4x


cat payment3.addr | cardano-address address inspect
{
    "stake_reference": "by value",
    "stake_key_hash_bech32": "stake_vkh1eu2e5vfh3uluwcjga8neanwjatkdsza9k9jda238uly556t7j9j",
    "stake_key_hash": "cf159a31378f3fc76248e9e79ecdd2eaecd80ba5b164deaa27e7c94a",
    "spending_key_hash_bech32": "addr_vkh1ydlxv2yhj4nujz3u6d72xxrxl0t6m77w4s0n2lj06axxke0nyw7",
    "address_style": "Shelley",
    "spending_key_hash": "237e6628979567c90a3cd37ca31866fbd7adfbceac1f357e4fd74c6b",
    "network_tag": 0,
    "address_type": 0
}


sancho_2_2_0=# select * from stake_address where hash_raw = '\xe0cf159a31378f3fc76248e9e79ecdd2eaecd80ba5b164deaa27e7c94a';
  id  |                           hash_raw                           |                               view                               | script_hash 
------+--------------------------------------------------------------+------------------------------------------------------------------+-------------
 1109 | \xe0cf159a31378f3fc76248e9e79ecdd2eaecd80ba5b164deaa27e7c94a | stake_test1ur83tx33x78nl3mzfr5708kd6t4wekqt5kckfh42ylnujjs2k6cxt | 
(1 row)


./cardano-cli query utxo --address $(cat payment3.addr) --testnet-magic 4
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
66ef8c3acd931caf5cd1f06ca24a8e06dd9a0f0f2e07149d9a57ee7f24e36e4e     0        9997828471 lovelace + TxOutDatumNone



Node 8.6-pre


Generate the registration certificate

- Register the stake address you previously created by generating a registration certificate:

./cardano-cli stake-address registration-certificate \
--stake-verification-key-file stake.vkey \
--key-reg-deposit-amt 2000000 \
--out-file registration.cert



- Build the transaction:

./cardano-cli conway transaction build \
--testnet-magic 4 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file registration.cert \
--out-file tx.raw
Estimated transaction fee: Lovelace 171177



Submit the certificate to the chain

- Sign the transaction:

./cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file stake.skey \
--testnet-magic 4 \
--out-file tx.signed


- Submit the transaction:

./cardano-cli transaction submit \
--testnet-magic 4 \
--tx-file tx.signed

Transaction successfully submitted.


cat payment.addr | cardano-address address inspect
{
  ...
    "stake_key_hash": "931153299dce29f185fb40f150fa024b224f47a029b99403358b5582",
  ...
}



sancho_2_2_0=# select * from stake_address where hash_raw = '\xe0931153299dce29f185fb40f150fa024b224f47a029b99403358b5582';
  id  |                           hash_raw                           |                               view                               | script_hash 
------+--------------------------------------------------------------+------------------------------------------------------------------+-------------
 1106 | \xe0931153299dce29f185fb40f150fa024b224f47a029b99403358b5582 | stake_test1uzf3z5efnh8znuv9ldq0z586qf9jyn685q5mn9qrxk94tqsvalmq8 | 
(1 row)


sancho_2_2_0=# select * from stake_registration where addr_id=1106;
 id  | addr_id | cert_index | epoch_no | tx_id 
-----+---------+------------+----------+-------
 537 |    1106 |          0 |      142 |  1399
(1 row)


sancho_2_2_0=# select * from tx where id = 1399;
  id  |                                hash                                | block_id | block_index |  out_sum   |  fee   | deposit | size | invalid_before | invalid_hereafter | valid_contract | script_size 
------+--------------------------------------------------------------------+----------+-------------+------------+--------+---------+------+----------------+-------------------+----------------+-------------
 1399 | \xebf3fe6b36b58a6e839aefa9e08abf965fb58046ad2dead4125c3dc2ae967261 |   614397 |           0 | 9997828691 | 171309 | 2000000 |  362 |                |                   | t              |           0
(1 row)




sancho_2_2_0=# select * from tx_in where id=1399;
  id  | tx_in_id | tx_out_id | tx_out_index | redeemer_id 
------+----------+-----------+--------------+-------------
 1399 |     1332 |      1323 |            0 |            
(1 row)




sancho_2_2_0=# select * from tx_out where tx_id=1399;
  id   | tx_id | index |                                                   address                                                    |                                                     address_raw                                                      | address_has_script |                        payment_cred                        | stake_address_id |   value    | data_hash | inline_datum_id | reference_script_id 
-------+-------+-------+--------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+--------------------+------------------------------------------------------------+------------------+------------+-----------+-----------------+---------------------
 52487 |  1399 |     0 | addr_test1qrtlplvlwgauvsljrgesrfg5lqgszk2wluk4tl3m57cj4y5nz9fjn8ww98cct76q79g05qjtyf850gpfhx2qxdvt2kpqxdu62q | \x00d7f0fd9f723bc643f21a3301a514f81101594eff2d55fe3ba7b12a92931153299dce29f185fb40f150fa024b224f47a029b99403358b5582 | f                  | \xd7f0fd9f723bc643f21a3301a514f81101594eff2d55fe3ba7b12a92 |             1106 | 9997828691 |           |                 |                    
(1 row)



Generate keys for the stake pool


Generate cold keys and the operational certificate for your pool:

./cardano-cli conway node key-gen \
--cold-verification-key-file cold.vkey \
--cold-signing-key-file cold.skey \
--operational-certificate-issue-counter-file opcert.counter


Generate the key-evolving-signature (KES) keys:

./cardano-cli conway node key-gen-KES \
--verification-key-file kes.vkey \
--signing-key-file kes.skey


Generate VRF keys:

./cardano-cli conway node key-gen-VRF \
--verification-key-file vrf.vkey \
--signing-key-file vrf.skey



Generate the registration and delegation certificates for the pool

Create your stake pool registration certificate:


./cardano-cli stake-pool registration-certificate \
--conway-era \
--cold-verification-key-file cold.vkey \
--vrf-verification-key-file vrf.vkey \
--pool-pledge 9000000000 \
--pool-cost 340000000 \
--pool-margin 0.05 \
--pool-reward-account-verification-key-file stake.vkey \
--pool-owner-stake-verification-key-file stake.vkey \
--testnet-magic 4 \
--pool-relay-ipv4 83.23.113.218 \
--pool-relay-port 3002 \
--out-file pool-registration.cert



Create a stake delegation certificate:

./cardano-cli stake-address delegation-certificate \
--conway-era \
--stake-verification-key-file stake.vkey \
--cold-verification-key-file cold.vkey \
--out-file delegation.cert


Submit the certificates in a transaction

Build, sign and submit the transaction

Build:

./cardano-cli conway transaction build \
--testnet-magic 4 \
--witness-override 3 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file pool-registration.cert \
--certificate-file delegation.cert \
--out-file tx.raw



Sign:

./cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file cold.skey \
--signing-key-file stake.skey \
--testnet-magic 4 \
--out-file tx.signed


Submit:

./cardano-cli transaction submit \
--testnet-magic 4 \
--tx-file tx.signed


Get your pool ID, you will need to get a delegation from the faucet:

./cardano-cli conway stake-pool id \
--cold-verification-key-file cold.vkey \
--output-format bech32 \
--out-file pool.id


cat pool.id 
pool1fzsrkdf37ycyl98ssfg960737ztcj73pzlwuw6l8qa7sqx90ku6


Faucet pool delegation:

{
  "success": true,
  "txid": "9122dabeb0e33d4a8e63297ae01d8e7f9e71bbc799887cd6a20d8dd99361e987"
}


Starting the node as a block-producer

Generate your operational certificate:


slotsPerKESPeriod=$(cat sancho/shelley-genesis.json | jq -r '.slotsPerKESPeriod')
slotNo=$(./cardano-cli query tip --testnet-magic 4 | jq -r '.slot')
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
./cardano-cli conway node issue-op-cert --kes-verification-key-file kes.vkey --cold-signing-key-file cold.skey --operational-certificate-issue-counter-file opcert.counter --kes-period ${kesPeriod} --out-file opcert.cert

echo $slotsPerKESPeriod //129600
echo $slotNo //12319070


Restart your node using your pool credentials:

./cardano-node run --topology sancho/topology.json \
--database-path sancho/db \
--socket-path sancho/node.socket \
--shelley-kes-key kes.skey \
--shelley-vrf-key vrf.skey \
--shelley-operational-certificate opcert.cert \
--port 3001 \
--config sancho/config.json



./cardano-cli query stake-snapshot \
--testnet-magic 4 \
--stake-pool-id $(cat pool.id)
{
    "pools": {
        "48a03b3531f1304f94f082505d3fd1f097897a2117ddc76be7077d00": {
            "stakeGo": 0,
            "stakeMark": 0,
            "stakeSet": 0
        }
    },
    "total": {
        "stakeGo": 3000000000000,
        "stakeMark": 3000000000000,
        "stakeSet": 3000000000000
    }
}


sancho_2_2_0=# select * from pool_hash where view='pool1fzsrkdf37ycyl98ssfg960737ztcj73pzlwuw6l8qa7sqx90ku6';
 id |                          hash_raw                          |                           view                           
----+------------------------------------------------------------+----------------------------------------------------------
 19 | \x48a03b3531f1304f94f082505d3fd1f097897a2117ddc76be7077d00 | pool1fzsrkdf37ycyl98ssfg960737ztcj73pzlwuw6l8qa7sqx90ku6
(1 row)


sancho_2_2_0=# select * from delegation where addr_id = 1106;
 id | addr_id | cert_index | pool_hash_id | active_epoch_no | tx_id | slot_no  | redeemer_id 
----+---------+------------+--------------+-----------------+-------+----------+-------------
 36 |    1106 |          1 |           19 |             144 |  1404 | 12318998 |            
(1 row)




Registering as a SanchoNet delegate representative (DRep)


Generate SanchoNet DRep keys and an ID

Generate a DRep key pair:

./cardano-cli conway governance drep key-gen \
--verification-key-file drep.vkey \
--signing-key-file drep.skey


cat drep.vkey
{
    "type": "DRepVerificationKey_ed25519",
    "description": "Delegate Representative Verification Key",
    "cborHex": "582011e398d38a308472b6a6a9f8548c36c77d388198dbf4152d041b4eb8f750ef9d"
}


cat drep.skey
{
    "type": "DRepSigningKey_ed25519",
    "description": "Delegate Representative Signing Key",
    "cborHex": "5820451c420ad02140aae5abae2d7776459aa5e7b64a642e723ce4fee43782232acb"
}


Generate a SanchoNet DRep ID:

./cardano-cli conway governance drep id \
--drep-verification-key-file drep.vkey \
--out-file drep.id


DRep ID Hex:

./cardano-cli conway governance drep id --drep-verification-key-file drep.vkey --output-format 'hex'
85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a7

DRep ID bech32:

cat drep.id 
drep1shdx6rv6xxsq5ws4fftnxqsdg02uufvfvnyzmpx3f6t6wr0wh0p




Generate the registration certificate

Create a SanchoNet DRep registration certificate
There are three ways to generate the certificate:

Using the drep.vkey file:

./cardano-cli conway governance drep registration-certificate \
--drep-verification-key-file drep.vkey \
--key-reg-deposit-amt 2000000 \
--out-file drep-register.cert



Using the DRep verification key:

./cardano-cli conway governance drep registration-certificate \
--drep-verification-key "$(cat drep.vkey | jq -r .cborHex | cut -c 5-)" \
--key-reg-deposit-amt 0 \
--out-file drep-register-2.cert


Using the DRep ID:

./cardano-cli conway governance drep registration-certificate \
--drep-key-hash $(cat drep.id) \
--key-reg-deposit-amt 0 \
--out-file drep-register-3.cert


cat drep-register.cert 
{
    "type": "CertificateShelley",
    "description": "DRep Key Registration Certificate",
    "cborHex": "84108200581c85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a700f6"
}


cat drep-register-2.cert 
{
    "type": "CertificateShelley",
    "description": "DRep Key Registration Certificate",
    "cborHex": "84108200581c85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a700f6"
}


cat drep-register-3.cert 
{
    "type": "CertificateShelley",
    "description": "DRep Key Registration Certificate",
    "cborHex": "84108200581c85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a700f6"
}





Submit certificate in a transaction

Submit the SanchoNet DRep registration certificate in a transaction.

Build:

./cardano-cli conway transaction build \
--testnet-magic 4 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file drep-register.cert \
--out-file tx.raw



Sign:

./cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file drep.skey \
--testnet-magic 4 \
--out-file tx.signed


Submit:

./cardano-cli conway transaction submit \
--testnet-magic 4 \
--tx-file tx.signed


./cardano-cli conway transaction submit --testnet-magic 4 --tx-file tx.signed
Command failed: transaction submit  Error: Error while submitting tx: ShelleyTxValidationError ShelleyBasedEraConway (ApplyTxError [ConwayCertsFailure (CertFailure (GovCertFailure (ConwayDRepIncorrectDeposit (Coin 0) (Coin 2000000))))])


./cardano-cli query protocol-parameters --testnet-magic 4 | grep 2000000
    "stakeAddressDeposit": 2000000,


./cardano-cli query protocol-parameters --testnet-magic 4 | grep -i deposit
    "stakeAddressDeposit": 2000000,
    "stakePoolDeposit": 500000000,


./cardano-cli conway query protocol-parameters --testnet-magic 4 | grep -i deposit
    "stakeAddressDeposit": 2000000,
    "stakePoolDeposit": 500000000,


DRep ID Hex:
85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a7

DRep ID bech32:
drep1shdx6rv6xxsq5ws4fftnxqsdg02uufvfvnyzmpx3f6t6wr0wh0p


sancho_2_2_0=# select * from drep_hash where raw='\x85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a7';
 id |                            raw                             |                           view                           | has_script 
----+------------------------------------------------------------+----------------------------------------------------------+------------
 68 | \x85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a7 | drep1shdx6rv6xxsq5ws4fftnxqsdg02uufvfvnyzmpx3f6t6wr0wh0p | f
(1 row)



sancho_2_2_0=# select * from drep_registration where drep_hash_id=68;
 id | tx_id | cert_index | deposit | drep_hash_id | voting_anchor_id 
----+-------+------------+---------+--------------+------------------
 14 |  1410 |          0 | 2000000 |           68 |                 
(1 row)



Delegate votes to a DRep


- ALWAYS ABSTAIN

How do we test that it will be voting later automatically like that ?

./cardano-cli conway stake-address vote-delegation-certificate \
--stake-verification-key-file stake.vkey \
--always-abstain \
--out-file vote-deleg-always-abstain.cert


cat vote-deleg-always-abstain.cert
{
    "type": "CertificateShelley",
    "description": "Vote Delegation Certificate",
    "cborHex": "83098200581c931153299dce29f185fb40f150fa024b224f47a029b99403358b55828102"
}



- ALWAYS NO CONFIDENCE

./cardano-cli conway stake-address vote-delegation-certificate \
--stake-verification-key-file stake2.vkey \
--always-no-confidence \
--out-file vote-deleg-always-no-confidence.cert


cat vote-deleg-always-no-confidence.cert 
{
    "type": "CertificateShelley",
    "description": "Vote Delegation Certificate",
    "cborHex": "83098200581ce61c9773e9d048c4580b00a6307be74999fdb9087335aa00a9b68db88103"
}



- VOTE REGISTERED DREP

Delegating to a registered SanchoNet DRep:


./cardano-cli conway stake-address vote-delegation-certificate \
--stake-verification-key-file stake3.vkey \
--drep-key-hash $(cat drep.id) \
--out-file vote-deleg-registered-drep.cert



cat vote-deleg-registered-drep.cert 
{
    "type": "CertificateShelley",
    "description": "Vote Delegation Certificate",
    "cborHex": "83098200581ccf159a31378f3fc76248e9e79ecdd2eaecd80ba5b164deaa27e7c94a8200581c85da6d0d9a31a00a3a154a5733020d43d5ce258964c82d84d14e97a7"
}





Submitting the certificate in a transaction


- ALWAYS ABSTAIN

./cardano-cli conway transaction build \
--testnet-magic 4 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file vote-deleg-always-abstain.cert \
--out-file tx.raw


./cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file stake.skey \
--testnet-magic 4 \
--out-file tx.signed


./cardano-cli conway transaction submit \
--testnet-magic 4 \
--tx-file tx.signed


- ALWAYS NO CONFIDENCE

./cardano-cli conway transaction build \
--testnet-magic 4 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment2.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment2.addr) \
--certificate-file vote-deleg-always-no-confidence.cert \
--out-file tx.raw


./cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment2.skey \
--signing-key-file stake2.skey \
--testnet-magic 4 \
--out-file tx.signed


./cardano-cli conway transaction submit \
--testnet-magic 4 \
--tx-file tx.signed


- VOTE REGISTERED DREP

./cardano-cli conway transaction build \
--testnet-magic 4 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment3.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment3.addr) \
--certificate-file vote-deleg-registered-drep.cert \
--out-file tx.raw


./cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment3.skey \
--signing-key-file stake3.skey \
--testnet-magic 4 \
--out-file tx.signed


./cardano-cli conway transaction submit \
--testnet-magic 4 \
--tx-file tx.signed

addr_id = stake address id for stake1, stake2 and stake3 in that order
addr_id IN (1106, 1107, 1109)


sancho_2_2_0=# select * from delegation_vote where addr_id IN (1106, 1107, 1109);
 id | addr_id | cert_index | drep_hash_id | tx_id | redeemer_id 
----+---------+------------+--------------+-------+-------------
 29 |    1106 |          0 |           11 |  1416 |            
 30 |    1107 |          0 |           70 |  1419 |            
 31 |    1109 |          0 |           68 |  1422 |            
(3 rows)



sancho_2_2_0=# select * from drep_hash where id in (11,70);
 id |                            raw                             |           view            | has_script 
----+------------------------------------------------------------+---------------------------+------------
 11 | \x00000000000000000000000000000000000000000000000000000000 | drep_always_abstain       | f
 70 | \x00000000000000000000000000000000000000000000000000000000 | drep_always_no_confidence | f
(2 rows)


sancho_2_2_0=# select * from drep_registration;
 id | tx_id | cert_index | deposit  | drep_hash_id | voting_anchor_id 
----+-------+------------+----------+--------------+------------------
  1 |  1069 |          0 |  2000000 |            1 |                1
  2 |  1070 |          0 | -2000000 |            1 |                 
  3 |  1071 |          0 |  2000000 |            1 |                1
  4 |  1090 |          0 |  2000000 |            4 |               10
  5 |  1112 |          0 |  2000000 |            7 |                1
  6 |  1113 |          0 |  2000000 |            8 |                1
  7 |  1142 |          0 |  2000000 |           21 |                1
  8 |  1165 |          0 |  2000000 |           33 |                 
  9 |  1179 |          0 |  2000000 |           37 |                 
 10 |  1348 |          0 |  2000000 |           41 |                 
 11 |  1354 |          0 |  2000000 |           45 |                 
 12 |  1386 |          0 |  2000000 |           62 |                 
 13 |  1390 |          0 |  2000000 |           64 |                 
 14 |  1410 |          0 |  2000000 |           68 |                 
(14 rows)


sancho_2_2_0=# select * from drep_distr;
 id | hash_id |   amount    | epoch_no | active_until 
----+---------+-------------+----------+--------------
  1 |       4 |  9495292324 |      141 |          160
  2 |      41 |  9995312564 |      142 |          161
  3 |       7 |  9995898796 |      142 |          161
  4 |       4 | 18489120276 |      142 |          161
  5 |      45 |  9495115603 |      142 |          161
(5 rows)



Generate committee member keys and certificates

Committee member cold keys


./cardano-cli conway governance committee key-gen-cold \
    --cold-verification-key-file cc-cold.vkey \
    --cold-signing-key-file cc-cold.skey


Generate the cold verification key hash:

./cardano-cli conway governance committee key-hash \
    --verification-key-file cc-cold.vkey > cc-key.hash


cat cc-key.hash
94d4db81bcf8a61965fcbd3f4d7d07cbc430c075c06e4ffd637f52fd


Hot key pair and authorization certificate

./cardano-cli conway governance committee key-gen-hot \
    --verification-key-file cc-hot.vkey \
    --signing-key-file cc-hot.skey


./cardano-cli conway governance committee create-hot-key-authorization-certificate \
    --cold-verification-key-file cc-cold.vkey \
    --hot-key-file cc-hot.vkey \
    --out-file cc-hot-key-authorization.cert


Submit the authorization certificate in a transaction:

./cardano-cli conway transaction build --testnet-magic 4 \
--tx-in "$(cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
--change-address $(cat payment.addr) \
--certificate-file cc-hot-key-authorization.cert \
--witness-override 2 \
--out-file tx.raw



./cardano-cli conway transaction sign \
  --testnet-magic 4 \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --signing-key-file cc-cold.skey \
  --out-file tx.signed


./cardano-cli conway transaction submit \
  --testnet-magic 4 \
  --tx-file tx.signed


sancho_2_2_0=# select * from committee_registration;
 id | tx_id | cert_index |                          cold_key                          |                          hot_key                           
----+-------+------------+------------------------------------------------------------+------------------------------------------------------------
  1 |  1428 |          0 | \x94d4db81bcf8a61965fcbd3f4d7d07cbc430c075c06e4ffd637f52fd | \x9c3861d6cb244fd328a32cdf1526d4350a24a26216262d905cb5c7b7
(1 row)


No errors in the logs after waiting for a while:

[db-sync-node:Info:58] [2023-10-23 22:04:27.25 UTC] Insert Conway Block: continuing epoch 130 (slot 77667/86400)
[db-sync-node:Info:58] [2023-10-23 22:11:55.16 UTC] Insert Conway Block: epoch 130, slot 11310115, block 541951, hash 13eb7ed3d82474cb9414ff0836ab56a8dcd6d3ecbf795b02e2783f952cc9ff45
[db-sync-node:Info:58] [2023-10-23 22:12:13.10 UTC] Insert Conway Block: epoch 130, slot 11310133, block 541952, hash 6ee3d8a55e28afedbc9bfd11799cb139e0252e43eaebfb6c94824c075a4ede9a
[db-sync-node:Info:58] [2023-10-23 22:13:04.15 UTC] Insert Conway Block: epoch 130, slot 11310184, block 541953, hash 12001b4333efcb963af1231f253ab1366e56bd101f0c3a9f52a9c3fa8ecbe4d2



Governance actions

Common aspects of all types of governance actions


You can get the last enacted governance action IDs with:

./cardano-cli conway query gov-state --testnet-magic 4 | jq .enactState.prevGovActionIds
{
  "pgaCommittee": null,
  "pgaConstitution": null,
  "pgaHardFork": null,
  "pgaPParamUpdate": {
    "govActionIx": 0,
    "txId": "0340da2aef7dea268368654f098a687256475d681252060f04d7353e1acb9cfa"
  }
}

./cardano-cli conway query gov-state --testnet-magic 4 | jq .nextRatifyState.nextEnactState.prevGovActionIds
{
  "pgaCommittee": null,
  "pgaConstitution": null,
  "pgaHardFork": null,
  "pgaPParamUpdate": {
    "govActionIx": 0,
    "txId": "0340da2aef7dea268368654f098a687256475d681252060f04d7353e1acb9cfa"
  }
}



constitution.txt

Full gist URL:

https://gist.githubusercontent.com/ArturWieczorek/a77f1b1ca8f2a65de40bb6ae1ae869c9/raw/86965418b4cd32ed08fd9399249b9526cb7c424c/constitution.txt

Shortened URL:

https://shorturl.at/fyAK6


HASH:

wget https://shorturl.at/fyAK6
mv fyAK6 constitution.txt

cat constitution.txt 
We are Cardano and we are going to change the world! This is a test of governance action creation!


b2sum -l 256 constitution.txt 
8a528a1fda4bf5eab177ea2f9982298db8f8f70e88da3105c314d36c82756b80  constitution.txt



justification.txt

Full gist URL:

https://gist.githubusercontent.com/ArturWieczorek/51d12d28d6e00c241481fe88752f0abc/raw/3aa15ee5d7bd897c09c06259b7783be7374ffad7/justification.txt


Shortened URL:
https://shorturl.at/twLY9

wget https://shorturl.at/twLY9
mv twLY9 rationale.txt

cat rationale.txt 
This is a test of governance action - justification.
This document describes the necessary reasoning and analysis for the proposed changes in constitution.txt

HASH:

b2sum -l 256 rationale.txt 
8ea0e52775909015b65546a3b1638a4700d9774707f1be31bc76aaff5df89146  rationale.txt



Update committee actions

Update committe to add a new CC member:
Assume that the individual or entity that you want to add as a CC member has generated cold keys and has provided the key hash 89181f26b47c3d3b6b127df163b15b74b45bba7c3b7a1d185c05c2de. You can then create the proposal with:


cat cc-key.hash
94d4db81bcf8a61965fcbd3f4d7d07cbc430c075c06e4ffd637f52fd

wget https://tinyurl.com/3wrwb2as
cat 3wrwb2as 
These are the reasons:  

1. First
2. Second 
3. Third

mv 3wrwb2as new-committee-rationale.txt

./cardano-cli query utxo --address $(cat payment.addr) --socket-path sancho/node.socket  --testnet-magic 4
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
1fb947f8a6f5614cfd0c9ac08ca00309af7994ce83e1813bcb7853bfcf5d4308     0        9495128891 lovelace + TxOutDatumNone

./cardano-cli conway governance action update-committee \
  --testnet \
  --governance-action-deposit 1000000000 \
  --stake-verification-key-file stake.vkey \
  --proposal-anchor-url https://tinyurl.com/3wrwb2as \
  --proposal-anchor-metadata-file new-committee-rationale.txt \
  --add-cc-cold-verification-key-hash 94d4db81bcf8a61965fcbd3f4d7d07cbc430c075c06e4ffd637f52fd \
  --epoch 143 \
  --quorum 1/100 \
  --governance-action-tx-id "1fb947f8a6f5614cfd0c9ac08ca00309af7994ce83e1813bcb7853bfcf5d4308" \
  --governance-action-index 0 \
  --out-file create-new-committee.action


./cardano-cli conway transaction build \
  --testnet-magic 4 \
  --tx-in "$(./cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
  --change-address "$(cat payment.addr)" \
  --proposal-file create-new-committee.action \
  --witness-override 2 \
  --out-file tx.raw


./cardano-cli conway transaction sign \
  --testnet-magic 4 \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --signing-key-file stake.skey \
  --out-file tx.signed


./cardano-cli conway transaction submit \
  --testnet-magic 4 \
  --tx-file tx.signed


./cardano-cli conway stake-address key-hash --stake-verification-key-file stake.vkey
931153299dce29f185fb40f150fa024b224f47a029b99403358b5582


./cardano-cli conway query gov-state --testnet-magic 4 | jq '.proposals.psGovActionStates | to_entries[]'

./cardano-cli conway query gov-state --testnet-magic 4 | jq -r --arg keyHash "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e" '.proposals.psGovActionStates | to_entries[] | select(.value.returnAddr.credential.keyHash | contains($keyHash)) | .value'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "c8e8871a99a3d0d1843932743793bb8634edd80f68c6a9d073f8ae08be79ce0b"
      },
      [],
      {
        "keyHash-6a61d3862e74df10872a7426c107dad8cea9d784da4a150741e64141": 138
      },
      0.51
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
  },
  "committeeVotes": {},
  "dRepVotes": {},
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}


Update committee to remove an existing CC member:

There is NO member at the moment




Update committee to change the quorum:


./cardano-cli query utxo --address $(cat payment.addr) --socket-path sancho/node.socket  --testnet-magic 4
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709     0        9999136151 lovelace + TxOutDatumNone


./cardano-cli conway governance action update-committee \
  --testnet \
  --governance-action-deposit 0 \
  --stake-verification-key-file stake.vkey \
  --proposal-url https://tinyurl.com/3wrwb2as \
  --proposal-file new-committee-rationale.txt \
  --quorum 33/100 \
  --governance-action-tx-id 4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709 \
  --governance-action-index 0 \
  --out-file update-committee-quorum.action


./cardano-cli conway transaction build \
  --testnet-magic 4 \
  --tx-in "$(cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
  --change-address "$(cat payment.addr)" \
  --proposal-file update-committee-quorum.action \
  --witness-override 2 \
  --out-file tx.raw


./cardano-cli conway transaction sign \
  --testnet-magic 4 \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --signing-key-file stake.skey \
  --out-file tx.signed


./cardano-cli conway transaction submit \
  --testnet-magic 4 \
  --tx-file tx.signed


./cardano-cli conway governance query gov-state --testnet-magic 4 | jq -r --arg keyHash "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e" '.gov.curGovSnapshots.psGovActionStates | to_entries[] | select(.value.returnAddr.credential.keyHash | contains($keyHash)) | .value'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "c8e8871a99a3d0d1843932743793bb8634edd80f68c6a9d073f8ae08be79ce0b"
      },
      [],
      {
        "keyHash-6a61d3862e74df10872a7426c107dad8cea9d784da4a150741e64141": 138
      },
      0.51
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
  },
  "committeeVotes": {},
  "dRepVotes": {},
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
      },
      [],
      {},
      0.33
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8"
  },
  "committeeVotes": {},
  "dRepVotes": {},
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}



Updating the constitution


Find the last enacted governance action of this type:


./cardano-cli conway governance query gov-state --testnet-magic 4 | jq .ratify.prevGovActionIds.pgaConstitution
{
  "govActionIx": 0,
  "txId": "e7256a28b03cf3425b8ef911016f894694b391dd4f9aa4377c29bf347ff3d5b5"
}


./cardano-cli query utxo --address $(cat payment.addr) --socket-path sancho/node.socket  --testnet-magic 4
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8     0        9998960090 lovelace + TxOutDatumNone


Create the action file:

./cardano-cli conway governance action create-constitution \
  --testnet \
  --governance-action-deposit 0 \
  --stake-verification-key-file stake.vkey \
  --proposal-url "https://shorturl.at/twLY9" \
  --proposal-hash "8ea0e52775909015b65546a3b1638a4700d9774707f1be31bc76aaff5df89146" \
  --constitution-url https://tinyurl.com/mr3ferf9  \
  --constitution-file constitution.txt \
  --governance-action-tx-id 793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8 \
  --governance-action-index 0 \
  --out-file constitution.action


./cardano-cli conway transaction build \
  --testnet-magic 4 \
  --tx-in "$(cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
  --change-address "$(cat payment.addr)" \
  --proposal-file constitution.action \
  --witness-override 2 \
  --out-file tx.raw


./cardano-cli conway transaction sign \
  --testnet-magic 4 \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --signing-key-file stake.skey \
  --out-file tx.signed


./cardano-cli conway transaction submit \
  --testnet-magic 4 \
  --tx-file tx.signed


NEW MEMEBR:
./cardano-cli conway governance query gov-state --testnet-magic 4 | jq -r '.gov.curGovSnapshots.psGovActionStates["4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709#0"]'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "c8e8871a99a3d0d1843932743793bb8634edd80f68c6a9d073f8ae08be79ce0b"
      },
      [],
      {
        "keyHash-6a61d3862e74df10872a7426c107dad8cea9d784da4a150741e64141": 138
      },
      0.51
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
  },
  "committeeVotes": {},
  "dRepVotes": {},
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}


NEW QUORUM:

./cardano-cli conway governance query gov-state --testnet-magic 4 | jq -r '.gov.curGovSnapshots.psGovActionStates["793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8#0"]'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
      },
      [],
      {},
      0.33
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8"
  },
  "committeeVotes": {},
  "dRepVotes": {},
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}



VOTING:

New quorum:

- Vote with DRep keys:

./cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8" \
    --governance-action-index "0" \
    --drep-verification-key-file drep.vkey \
    --out-file 793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8-update-quorum.vote



Include the vote in a transaction:


./cardano-cli conway transaction build --testnet-magic 4 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file 793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8-update-quorum.vote \
    --witness-override 2 \
    --out-file vote-tx.raw

Sign it with the DRep key:

./cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file drep.skey \
    --signing-key-file payment.skey \
    --testnet-magic 4 \
    --out-file vote-tx.signed


./cardano-cli transaction submit --testnet-magic 4 --tx-file vote-tx.signed


./cardano-cli conway governance query gov-state --testnet-magic 4 | jq -r '.gov.curGovSnapshots.psGovActionStates["793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8#0"]'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
      },
      [],
      {},
      0.33
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8"
  },
  "committeeVotes": {},
  "dRepVotes": {
    "keyHash-101c6b88b3f337c6be99238200ad7634171b0b125512bfbe977ffc96": "VoteYes"
  },
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}



Vote with CC hot keys:


./cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8" \
    --governance-action-index "0" \
    --cc-hot-verification-key-file "cc-hot.vkey" \
    --out-file 793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8-update-quorum-cc.vote


Include the vote in a transaction:


./cardano-cli conway transaction build --testnet-magic 4 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file 793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8-update-quorum-cc.vote \
    --witness-override 2 \
    --out-file vote-tx.raw

Sign it with the CC hot key:

./cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file cc-hot.skey \
    --signing-key-file payment.skey \
    --testnet-magic 4 \
    --out-file vote-tx.signed


./cardano-cli transaction submit --testnet-magic 4 --tx-file vote-tx.signed



./cardano-cli transaction submit --testnet-magic 4 --tx-file vote-tx.signed
Command failed: transaction submit  Error: Error while submitting tx: 
ShelleyTxValidationError ShelleyBasedEraConway (ApplyTxError [ConwayGovFailure (DisallowedVoters (fromList [(GovActionId {gaidTxId = TxId {unTxId = SafeHash "793a90a75e708f04f1aef1a0af76cac84e45fea6a1f250e8f7f9b20a80a4b3c8"}, gaidGovActionIx = GovActionIx 0},CommitteeVoter (KeyHashObj (KeyHash "a600465da048f21ac753b26e4c136e7af51352d4ac77aa02c41c1c9f")))]))])



Voting for new committee member:


NEW MEMEBR:

./cardano-cli conway governance query gov-state --testnet-magic 4 | \
jq -r '.gov.curGovSnapshots.psGovActionStates["4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709#0"]'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "c8e8871a99a3d0d1843932743793bb8634edd80f68c6a9d073f8ae08be79ce0b"
      },
      [],
      {
        "keyHash-6a61d3862e74df10872a7426c107dad8cea9d784da4a150741e64141": 138
      },
      0.51
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
  },
  "committeeVotes": {},
  "dRepVotes": {},
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}


Vote with DRep keys:

./cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709" \
    --governance-action-index "0" \
    --drep-verification-key-file drep.vkey \
    --out-file 4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709-new-cc-member.vote


Include the vote in a transaction

./cardano-cli conway transaction build --testnet-magic 4 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file 4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709-new-cc-member.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


./cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file drep.skey \
    --signing-key-file payment.skey \
    --testnet-magic 4 \
    --out-file vote-tx.signed


./cardano-cli conway governance query gov-state --testnet-magic 4 | jq -r '.gov.curGovSnapshots.psGovActionStates["4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709#0"]'
{
  "action": {
    "contents": [
      {
        "govActionIx": 0,
        "txId": "c8e8871a99a3d0d1843932743793bb8634edd80f68c6a9d073f8ae08be79ce0b"
      },
      [],
      {
        "keyHash-6a61d3862e74df10872a7426c107dad8cea9d784da4a150741e64141": 138
      },
      0.51
    ],
    "tag": "UpdateCommittee"
  },
  "actionId": {
    "govActionIx": 0,
    "txId": "4ec114ce49b02ff6c2ef595002eca6b82f69fd2c0bc01476d3e1a0267447c709"
  },
  "committeeVotes": {},
  "dRepVotes": {
    "keyHash-101c6b88b3f337c6be99238200ad7634171b0b125512bfbe977ffc96": "VoteYes"
  },
  "deposit": 0,
  "expiresAfter": 151,
  "proposedIn": 137,
  "returnAddr": {
    "credential": {
      "keyHash": "cec71f5db51924ec185b2d2e5d30d84c889a6c0e273b8ae939f8272e"
    },
    "network": "Testnet"
  },
  "stakePoolVotes": {}
}




/////// BELOW OLD

cat constitution.action
{
    "type": "Governance proposal",
    "description": "",
    "cborHex": "841a000f4240581de0511c03a02fbc8b1947d934ce86eefc9a934bfafe8f1efb40d59674068305f68282781968747470733a2f2f73686f727475726c2e61742f6679414b3658203028e2407fb9ddeb14fdca981b8b71f5969713bd014fbf20991ca00d217c523ef682781968747470733a2f2f73686f727475726c2e61742f74774c59395820a414b6545a9623c3359291d798d5841729d2800bbd7d81111a7600ebb4300718"
}



Submitting the governance action in a transaction

You can now build a transaction with the proposal:

./../_cardano-cli transaction build --testnet-magic 4 --conway-era \
  --tx-in cbbf9dabb261b4f263fc18305aed41a6c64e42355132fe7e6dd54bdb4db3280c#0 \
  --change-address $(cat payment.addr) \
  --constitution-file constitution.action \
  --witness-override 2 \
  --out-file tx.raw
Estimated transaction fee: Lovelace 177073



Sign the transaction with your cold.skey and a payment.skey:

./../_cardano-cli transaction sign \
  --tx-body-file tx.raw \
  --signing-key-file stake.skey \
  --signing-key-file payment.skey \
  --testnet-magic 4 \
  --out-file tx.signed


Submit the transaction to the chain:

./../_cardano-cli transaction submit \
  --testnet-magic 4 \
  --tx-file tx.signed

Transaction successfully submitted.


sancho=# select * from voting_anchor where url='https://shorturl.at/twLY9';
 id | tx_id |            url            |                             data_hash                              
----+-------+---------------------------+--------------------------------------------------------------------
  6 |  2430 | https://shorturl.at/twLY9 | \xa414b6545a9623c3359291d798d5841729d2800bbd7d81111a7600ebb4300718
(1 row)

sancho=# select * from governance_action where tx_id=2430;
 id | tx_id | index | deposit | return_address | voting_anchor_id |      type       |                                                                                                                          description                                                                                                                           | param_proposal | ratified_epoch | enacted_epoch | dropped_epoch | expired_epoch 
----+-------+-------+---------+----------------+------------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------+---------------+---------------+---------------
 16 |  2430 |     0 | 1000000 |           1628 |                6 | NewConstitution | NewConstitution SNothing (Constitution {constitutionAnchor = Anchor {anchorUrl = Url {urlToText = "https://shorturl.at/fyAK6"}, anchorDataHash = SafeHash "3028e2407fb9ddeb14fdca981b8b71f5969713bd014fbf20991ca00d217c523e"}, constitutionScript = SNothing}) |                |                |               |               |              
(1 row)


sancho=# select * from voting_procedure where governance_action_id=16;
 id | tx_id | index | governance_action_id | voter_role | comittee_voter | drep_voter | pool_voter | vote | voting_anchor_id 
----+-------+-------+----------------------+------------+----------------+------------+------------+------+------------------
 21 |  2431 |     0 |                   16 | DRep       |                |         22 |            | Yes  |                 
(1 row)



Getting the governance action ID


You need the action ID to share it with others on Discord1 and seek their 
support for your action. The simplest method to obtain it is by querying 
the balance again. The transaction ID and index of the transaction that 
submitted the constitution proposal serve as the action ID. 
Therefore, the command:


./../_cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]'

should provide the UTXO that created the constitution proposal:

792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89#0



Sometimes, it might be helpful to query the ledger state to filter actions by a key hash:

keyhash=$(bech32 <<< $(./../_cardano-cli stake-address build --stake-verification-key-file stake.vkey --testnet-magic 4) | cut -c 3-)

echo $keyhash
511c03a02fbc8b1947d934ce86eefc9a934bfafe8f1efb40d5967406



./../_cardano-cli query ledger-state --testnet-magic 4 | jq -r --arg keyhash "$keyhash" '.stateBefore.esLState.utxoState.ppups.gov | to_entries[] | select(.value.returnAddr.credential."key hash" == $keyhash)'
{
  "key": "792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89#0",
  "value": {
    "committeeVotes": [],
    "dRepVotes": [],
    "stakePoolVotes": {},
    "deposit": 1000000,
    "returnAddr": {
      "credential": {
        "key hash": "511c03a02fbc8b1947d934ce86eefc9a934bfafe8f1efb40d5967406"
      },
      "network": "Testnet"
    },
    "action": {
      "contents": [
        null,
        {
          "constitutionAnchor": {
            "dataHash": "3028e2407fb9ddeb14fdca981b8b71f5969713bd014fbf20991ca00d217c523e",
            "url": "https://shorturl.at/fyAK6"
          }
        }
      ],
      "tag": "NewConstitution"
    },
    "proposedIn": 96
  }
}


To get only key:

./../_cardano-cli query ledger-state --testnet-magic 4 | jq -r --arg keyhash "$keyhash" '.stateBefore.esLState.utxoState.ppups.gov | to_entries[] | select(.value.returnAddr.credential."key hash" == $keyhash)' |jq .key

"792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89#0"



Create the vote file

Vote with DRep keys

./../_cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89" \
    --governance-action-index "0" \
    --drep-verification-key-file drep.vkey \
    --out-file 792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89-constitution.vote



Include the vote in a transaction:

Build, sign, and submit the transaction:

./../_cardano-cli transaction build --testnet-magic 4 --conway-era \
    --tx-in 792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89#0 \
    --change-address $(cat payment.addr) \
    --vote-file 792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89-constitution.vote \
    --witness-override 2 \
    --out-file vote-tx.raw
Estimated transaction fee: Lovelace 172937


./../_cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file drep.skey \
    --signing-key-file payment.skey \
    --testnet-magic 4 \
    --out-file vote-tx.signed

./../_cardano-cli transaction submit --testnet-magic 4 --tx-file vote-tx.signed
Transaction successfully submitted.



./../_cardano-cli query ledger-state --testnet-magic 4 | jq -r --arg keyhash "$keyhash" '.stateBefore.esLState.utxoState.ppups.gov | to_entries[] | select(.value.returnAddr.credential."key hash" == $keyhash)'
{
  "key": "792e8e504f2e84dad6920cc17684b98baf658d794d148bfab56d29c59615fa89#0",
  "value": {
    "committeeVotes": [],
    "dRepVotes": [
      [
        {
          "key hash": "130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c"
        },
        "VoteYes"
      ]
    ],
    "stakePoolVotes": {},
    "deposit": 1000000,
    "returnAddr": {
      "credential": {
        "key hash": "511c03a02fbc8b1947d934ce86eefc9a934bfafe8f1efb40d5967406"
      },
      "network": "Testnet"
    },
    "action": {
      "contents": [
        null,
        {
          "constitutionAnchor": {
            "dataHash": "3028e2407fb9ddeb14fdca981b8b71f5969713bd014fbf20991ca00d217c523e",
            "url": "https://shorturl.at/fyAK6"
          }
        }
      ],
      "tag": "NewConstitution"
    },
    "proposedIn": 96
  }
}



Questions:

Why there is 2 x AlwaysAbstain ? drep_hash should always have unique entries ?

sancho=# select * from drep_hash;                       
 id |                            raw                             |     view      | has_script 
----+------------------------------------------------------------+---------------+------------
  1 | \x8fe12ca3a1cff93f4b4d7b7c018bf2e95c55627c15d7da3e6b8c9257 |               | f
  2 | \xd3a62ffe9c214e1a6a9809f7ab2a104c117f85e1f171f8f839d94be5 |               | f
  3 | \xd3a62ffe9c214e1a6a9809f7ab2a104c117f85e1f171f8f839d94be5 |               | f
  4 | \xd3a62ffe9c214e1a6a9809f7ab2a104c117f85e1f171f8f839d94be5 |               | f
  5 | \xd3a62ffe9c214e1a6a9809f7ab2a104c117f85e1f171f8f839d94be5 |               | f
  6 | \xd3a62ffe9c214e1a6a9809f7ab2a104c117f85e1f171f8f839d94be5 |               | f
  7 | \x5fe5d4dcdf21d7c975b3bf7d096df10ff530fe28c6faaaa0b8a76a83 |               | f
  8 | \xd031981a0d4b3ac833314ff7c678eb24d301624b457af4455fe11b32 |               | f
  9 | \xd031981a0d4b3ac833314ff7c678eb24d301624b457af4455fe11b32 |               | f
 10 | \x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c |               | f
 11 | \x12efd3fd1ae6a463b65bc54b450d9d716677ceb2039f61db119c4d7a |               | f
 12 | \x12efd3fd1ae6a463b65bc54b450d9d716677ceb2039f61db119c4d7a |               | f
 13 | \x0ff4339d8510c6d1071a800038e0cf2ad6ab623d23ab12ab653850a5 |               | f
 14 | \x2009a7714881f439f298ab212f70cccdf1bb23f5c8a23136de803289 |               | f
 15 |                                                            | AlwaysAbstain | f
 16 |                                                            | AlwaysAbstain | f
 17 | \x2009a7714881f439f298ab212f70cccdf1bb23f5c8a23136de803289 |               | f
 18 | \x2009a7714881f439f298ab212f70cccdf1bb23f5c8a23136de803289 |               | f
 19 | \x0ff4339d8510c6d1071a800038e0cf2ad6ab623d23ab12ab653850a5 |               | f
 20 | \x5fe5d4dcdf21d7c975b3bf7d096df10ff530fe28c6faaaa0b8a76a83 |               | f
 21 | \x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c |               | f
 22 | \x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c |               | f
(22 rows)


Should be empty ?

sancho=# select * from anchor_offline_data;
 id | voting_anchor_id | hash | json | bytes 
----+------------------+------+------+-------
(0 rows)

sancho=# select * from anchor_offline_fetch_error;
 id | voting_anchor_id | fetch_error | retry_count 
----+------------------+-------------+-------------
(0 rows)

From Kostas:
Some tables/fields are created but are not populated yet: 
anchor_offline_data, anchor_offline_fetch_error, drep_distr, 
governance_action.x_epoch , delegation_vote.redeemer_id


Why 3 same entries ? Issue

sancho=# select * from drep_hash where raw='\x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c';
 id |                            raw                             | view | has_script 
----+------------------------------------------------------------+------+------------
 10 | \x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c |      | f
 21 | \x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c |      | f
 22 | \x130c4eadb531d9bf48b2ccc11d150d93587136b4edd76e28836bd54c |      | f
(3 rows)


