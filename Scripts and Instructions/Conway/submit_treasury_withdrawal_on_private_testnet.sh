


cardano-cli conway governance action create-treasury-withdrawal



Generate payment keys:

cardano-cli conway address key-gen \
--verification-key-file payment.vkey \
--signing-key-file payment.skey

Generate stake keys:

cardano-cli conway stake-address key-gen \
--verification-key-file stake.vkey \
--signing-key-file stake.skey


Build your address:

cardano-cli conway address build \
--payment-verification-key-file payment.vkey \
--stake-verification-key-file stake.vkey \
--out-file payment.addr \
--testnet-magic 42

cat payment.addr 
addr_test1qr2skrzusj9l70sqr786fv6hp3u0wgjpe52f43wualzg33mynv776rcczqppewzy644qg5c3gzfxvwhy6u4qetarr3jq4xmdya

cardano-cli conway address key-hash --payment-verification-key-file payment.vkey 
d50b0c5c848bff3e001f8fa4b3570c78f72241cd149ac5dcefc488c7

===================================================================================

PAYMENT 2 ADDRESS:

cardano-cli conway address key-gen \
--verification-key-file payment2.vkey \
--signing-key-file payment2.skey

Generate stake keys:

cardano-cli conway stake-address key-gen \
--verification-key-file stake2.vkey \
--signing-key-file stake2.skey


Build your address:

cardano-cli conway address build \
--payment-verification-key-file payment2.vkey \
--stake-verification-key-file stake2.vkey \
--out-file payment2.addr \
--testnet-magic 42

cat payment2.addr 
addr_test1qrya7gz3gw5fjrlelz8m3v5k4w4f68adqzthu7hfqyhxqvv4j8nqe73kz33wptrgfdu4z5c32smjuhlrl4gj6lrv705smpnf5j

cardano-cli conway address key-hash --payment-verification-key-file payment2.vkey 
c9df205143a8990ff9f88fb8b296abaa9d1fad00977e7ae9012e6031


====================================================================================


PAYMENT 3 ADDRESS:

cardano-cli conway address key-gen \
--verification-key-file payment3.vkey \
--signing-key-file payment3.skey

Generate stake keys:

cardano-cli conway stake-address key-gen \
--verification-key-file stake3.vkey \
--signing-key-file stake3.skey


Build your address:

cardano-cli conway address build \
--payment-verification-key-file payment3.vkey \
--stake-verification-key-file stake3.vkey \
--out-file payment3.addr \
--testnet-magic 42

cat payment3.addr 
addr_test1qqyshjm67ypr5aqpjr3dsp5jvy3vvy3htstaxxll3jqeqjf9tvakuw56sn8wwany29r0j0l8ze2yp9wyev2yq2yprheqnptmtv

cardano-cli conway address key-hash --payment-verification-key-file payment3.vkey 
090bcb7af1023a740190e2d806926122c612375c17d31bff8c819049



export CARDANO_NODE_SOCKET_PATH=/home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/pool1.socket

PAYMENT ADDRESS HAS NO FUNDS:

cardano-cli conway query utxo --address $(cat payment.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------



SENDING FUNDS FROM GENESIS:


cardano-cli conway query utxo --address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
31e2889feedae1f9d13588460ebc17b4bf79a923200731b225ae587fc4218182     3        29990039997118403 lovelace + TxOutDatumNone






cardano-cli conway transaction build \
--tx-in 31e2889feedae1f9d13588460ebc17b4bf79a923200731b225ae587fc4218182#3 \
--tx-out $(cat payment.addr)+2000000000000 \
--change-address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) \
--out-file tx.raw \
--witness-override 2 \
--testnet-magic 42
Estimated transaction fee: Coin 176105

where payment.addr is the Shelley address created manually by the user and 
--witness-override 2 is used because of this issue.


Sign tx:

cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file dev_workdir/state-cluster0/shelley/genesis-utxo.skey \
--testnet-magic 42 \
--out-file tx.signed


Submit tx:

cardano-cli conway transaction submit --tx-file tx.signed  --testnet-magic 42
Transaction successfully submitted.


CHECKING FUNDS:

cardano-cli conway query utxo --address $(cat payment.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
4436f269305c37fdf5325ff5495d3705d493123b9c2f9463a2764b105b7ce6fd     0        2000000000000 lovelace + TxOutDatumNone


==============================================================================

TO PAYMENT ADDRESS 2:

cardano-cli conway query utxo --address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
4436f269305c37fdf5325ff5495d3705d493123b9c2f9463a2764b105b7ce6fd     1        29988039996942298 lovelace + TxOutDatumNone



cardano-cli conway transaction build \
--tx-in 4436f269305c37fdf5325ff5495d3705d493123b9c2f9463a2764b105b7ce6fd#1 \
--tx-out $(cat payment2.addr)+90000000000 \
--change-address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) \
--out-file tx.raw \
--witness-override 2 \
--testnet-magic 42


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file dev_workdir/state-cluster0/shelley/genesis-utxo.skey \
--testnet-magic 42 \
--out-file tx.signed



cardano-cli conway transaction submit --tx-file tx.signed  --testnet-magic 42


CHECKING FUNDS:

cardano-cli conway query utxo --address $(cat payment2.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
75a72a305b31b080a639770ad13be480cd56185cb629cb42997424e371b63f76     0        90000000000 lovelace + TxOutDatumNone



=============================================================================

=======================================

TO PAYMENT ADDRESS 3:

cardano-cli conway query utxo --address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) --testnet-magic 42
 
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
75a72a305b31b080a639770ad13be480cd56185cb629cb42997424e371b63f76     1        29987949996766193 lovelace + TxOutDatumNone


cardano-cli conway transaction build \
--tx-in 75a72a305b31b080a639770ad13be480cd56185cb629cb42997424e371b63f76#1 \
--tx-out $(cat payment3.addr)+190000000000 \
--change-address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) \
--out-file tx.raw \
--witness-override 2 \
--testnet-magic 42


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file dev_workdir/state-cluster0/shelley/genesis-utxo.skey \
--testnet-magic 42 \
--out-file tx.signed



cardano-cli conway transaction submit --tx-file tx.signed  --testnet-magic 42


CHECKING FUNDS:

cardano-cli conway query utxo --address $(cat payment3.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
3cd96c61396f76d0b4aa56ce677b5b1864bda3d41c5ce297a8b843e0d61bb69d     0        190000000000 lovelace + TxOutDatumNone




cat payment.addr | cardano-address address inspect
{
    "stake_reference": "by value",
    "stake_key_hash_bech32": "stake_vkh1vjdnmmg0rqgqy89cgn2k5pznz9qfye36untj5r905vwxgjnmcf5",
    "stake_key_hash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64",
    "spending_key_hash_bech32": "addr_vkh1659schyy30lnuqql37jtx4cv0rmjyswdzjdvth80cjyvw97vn4a",
    "address_style": "Shelley",
    "spending_key_hash": "d50b0c5c848bff3e001f8fa4b3570c78f72241cd149ac5dcefc488c7",
    "network_tag": 0,
    "address_type": 0
}

cat payment2.addr | cardano-address address inspect
{
    "stake_reference": "by value",
    "stake_key_hash_bech32": "stake_vkh1jkg7vr86xc2x9c9vdp9hj52nz92rwtjlu074zttudne7j95zsmy",
    "stake_key_hash": "9591e60cfa361462e0ac684b7951531154372e5fe3fd512d7c6cf3e9",
    "spending_key_hash_bech32": "addr_vkh1e80jq52r4zvsl70c37ut994t42w3ltgqjal846gp9esrzekdcrn",
    "address_style": "Shelley",
    "spending_key_hash": "c9df205143a8990ff9f88fb8b296abaa9d1fad00977e7ae9012e6031",
    "network_tag": 0,
    "address_type": 0
}

cat payment3.addr | cardano-address address inspect
{
    "stake_reference": "by value",
    "stake_key_hash_bech32": "stake_vkh1y4dnkm36n2zvaemkv3g5d7fluut9gsy4cn93gspgsywlyae0t52",
    "stake_key_hash": "255b3b6e3a9a84cee776645146f93fe716544095c4cb144028811df2",
    "spending_key_hash_bech32": "addr_vkh1py9uk7h3qga8gqvsutvqdynpytrpyd6uzlf3hluvsxgyj487gj8",
    "address_style": "Shelley",
    "spending_key_hash": "090bcb7af1023a740190e2d806926122c612375c17d31bff8c819049",
    "network_tag": 0,
    "address_type": 0
}


Generate the registration certificate

STAKE 1

cardano-cli conway stake-address registration-certificate \
--stake-verification-key-file stake.vkey \
--key-reg-deposit-amt 400000 \
--out-file registration.cert


cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file registration.cert \
--out-file tx.raw


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file stake.skey \
--testnet-magic 42 \
--out-file tx.signed


cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed

Transaction successfully submitted.


============================================================

STAKE 2

cardano-cli conway stake-address registration-certificate \
--stake-verification-key-file stake2.vkey \
--key-reg-deposit-amt 400000 \
--out-file registration2.cert


cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment2.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment2.addr) \
--certificate-file registration2.cert \
--out-file tx.raw


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment2.skey \
--signing-key-file stake2.skey \
--testnet-magic 42 \
--out-file tx.signed


cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed


============================================================

STAKE 3

cardano-cli conway stake-address registration-certificate \
--stake-verification-key-file stake3.vkey \
--key-reg-deposit-amt 400000 \
--out-file registration3.cert


cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment3.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment3.addr) \
--certificate-file registration3.cert \
--out-file tx.raw


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment3.skey \
--signing-key-file stake3.skey \
--testnet-magic 42 \
--out-file tx.signed


cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed


============================================================



Submitting Treasury Withdrawal:

govActionDeposit=100000000

{
  "poolVotingThresholds": {
    "motionNoConfidence": 0.51,
    "committeeNormal": 0.51,
    "committeeNoConfidence": 0.51,
    "hardForkInitiation": 0.51,
    "ppSecurityGroup": 0.51
 },
  "dRepVotingThresholds": {
    "motionNoConfidence": 0.51,
    "committeeNormal": 0.51,
    "committeeNoConfidence": 0.51,
    "updateToConstitution": 0.51,
    "hardForkInitiation": 0.51,
    "ppNetworkGroup": 0.51,
    "ppEconomicGroup": 0.51,
    "ppTechnicalGroup": 0.51,
    "ppGovGroup": 0.51,
    "treasuryWithdrawal": 0.51
  },
  "committeeMinSize": 0,
  "committeeMaxTermLength": 11000,
  "govActionLifetime": 2,
  "govActionDeposit": 100000000,
  "dRepDeposit": 2000000,
  "dRepActivity": 100,
  "minFeeRefScriptCostPerByte": 0


My stake key:

hash_raw=\xe0649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64 | 
view=stake_test1upjfk00dpuvpqqsuhpzd26sy2vg5pynx8tjdw2sv4733ceq4lluan |


| \xe0649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64 | stake_test1upjfk00dpuvpqqsuhpzd26sy2vg5pynx8tjdw2sv4733ceq4lluan | 
| \xe09591e60cfa361462e0ac684b7951531154372e5fe3fd512d7c6cf3e9 | stake_test1uz2eresvlgmpgchq435yk7232vg4gdewtl3l65fd03k086gufgfl6 | 
| \xe0255b3b6e3a9a84cee776645146f93fe716544095c4cb144028811df2 | stake_test1uqj4kwmw82dgfnh8wej9z3he8ln3v4zqjhzvk9zq9zq3musphuk90 | 


CREATING DREPS:

DREP 1:

cardano-cli conway governance drep key-gen \
--verification-key-file drep1.vkey \
--signing-key-file drep1.skey


cardano-cli conway governance drep id \
--drep-verification-key-file drep1.vkey \
--out-file drep1.id

cat drep1.id 
drep192e2600p9l7x745ee4tr2j7hkskuzhvc45lj0pf56pavkf6rv82


cardano-cli conway governance drep registration-certificate \
--drep-verification-key-file drep1.vkey \
--key-reg-deposit-amt 2000000 \
--out-file drep1-register.cert


cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file drep1-register.cert \
--out-file tx.raw


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file drep1.skey \
--testnet-magic 42 \
--out-file tx.signed


cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed


DREP 2:

cardano-cli conway governance drep key-gen \
--verification-key-file drep2.vkey \
--signing-key-file drep2.skey


cardano-cli conway governance drep id \
--drep-verification-key-file drep2.vkey \
--out-file drep2.id

cat drep2.id 
drep16myxqjttvk3g82cr7fgy3sypa428h6hxcgnmv3220w2vsdzuqmp


cardano-cli conway governance drep registration-certificate \
--drep-verification-key-file drep2.vkey \
--key-reg-deposit-amt 2000000 \
--out-file drep2-register.cert


cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment2.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment2.addr) \
--certificate-file drep2-register.cert \
--out-file tx.raw


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment2.skey \
--signing-key-file drep2.skey \
--testnet-magic 42 \
--out-file tx.signed


cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed


DREP 3:

cardano-cli conway governance drep key-gen \
--verification-key-file drep3.vkey \
--signing-key-file drep3.skey


cardano-cli conway governance drep id \
--drep-verification-key-file drep3.vkey \
--out-file drep3.id

cat drep3.id 
drep16myxqjttvk3g82cr7fgy3sypa428h6hxcgnmv3220w2vsdzuqmp


cardano-cli conway governance drep registration-certificate \
--drep-verification-key-file drep3.vkey \
--key-reg-deposit-amt 2000000 \
--out-file drep3-register.cert


cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment3.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment3.addr) \
--certificate-file drep3-register.cert \
--out-file tx.raw


cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment3.skey \
--signing-key-file drep3.skey \
--testnet-magic 42 \
--out-file tx.signed


cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed


select * from drep_registration;
 id | tx_id | cert_index | deposit  | drep_hash_id | voting_anchor_id 
----+-------+------------+----------+--------------+------------------
  1 |    20 |          0 |  2000000 |            1 |                 
  2 |    21 |          0 |  2000000 |            2 |                 
  3 |    31 |          0 | -2000000 |            1 |                 
  4 |    32 |          0 | -2000000 |            2 |                 
  5 |    37 |          0 |  2000000 |            7 |                 
  6 |    38 |          0 |  2000000 |            8 |                 
  7 |    39 |          0 |  2000000 |            9 |                 
(7 rows)




CREATING PROPOSAL:


cardano-cli conway governance action create-treasury-withdrawal --testnet --governance-action-deposit 100000000 --deposit-return-stake-verification-key-file stake.vkey --anchor-url  https://tinyurl.com/yc74fxx4 --anchor-data-hash 931f1d8cdfdc82050bd2baadfe384df8bf99b00e36cb12bfb8795beab3ac7fe5 --funds-receiving-stake-verification-key-file stake.vkey --transfer 1234512345 --out-file gov.action


  cardano-cli conway transaction build \
  --testnet-magic 42 \
  --tx-in "$(cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
  --change-address $(cat payment.addr) \
  --proposal-file gov.action \
  --out-file tx.raw

  cardano-cli conway transaction sign \
  --testnet-magic 42 \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --out-file tx.signed


  cardano-cli conway transaction submit \
  --testnet-magic 42 \
  --tx-file tx.signed


cardano-cli conway query gov-state --testnet-magic 42

    "proposals": [
        {
            "actionId": {
                "govActionIx": 0,
                "txId": "aab5f69a028c87b056b931f8bf684aafd4c2c9230993503848fd4983c0634277"
            },
            "committeeVotes": {},
            "dRepVotes": {},
            "expiresAfter": 11,
            "proposalProcedure": {
                "anchor": {
                    "dataHash": "931f1d8cdfdc82050bd2baadfe384df8bf99b00e36cb12bfb8795beab3ac7fe5",
                    "url": "https://tinyurl.com/yc74fxx4"
                },
                "deposit": 100000000,
                "govAction": {
                    "contents": [
                        [
                            [
                                {
                                    "credential": {
                                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                                    },
                                    "network": "Testnet"
                                },
                                1234512345
                            ]
                        ],
                        null
                    ],
                    "tag": "TreasuryWithdrawals"
                },
                "returnAddr": {
                    "credential": {
                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                    },
                    "network": "Testnet"
                }
            },
            "proposedIn": 9,
            "stakePoolVotes": {}
        }
    ]
}

cardano-cli conway query tip --testnet-magic 42

cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --cc-hot-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member1_committee_hot.vkey \
    --out-file cc1.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file cc1.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli conway transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member1_committee_hot.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli conway transaction submit --testnet-magic 42 --tx-file vote-tx.signed


/////////////////////////////////////////////


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --cc-hot-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member2_committee_hot.vkey \
    --out-file cc2.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file cc2.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli conway transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member2_committee_hot.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli conway transaction submit --testnet-magic 42 --tx-file vote-tx.signed


/////////////////////////////////////////////



cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --cc-hot-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member3_committee_hot.vkey \
    --out-file cc3.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file cc3.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli conway transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member3_committee_hot.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli conway transaction submit --testnet-magic 42 --tx-file vote-tx.signed



/////////////////////////////////////////////


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --cc-hot-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member4_committee_hot.vkey \
    --out-file cc4.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file cc4.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli conway transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member4_committee_hot.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli conway transaction submit --testnet-magic 42 --tx-file vote-tx.signed


/////////////////////////////////////////////


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --cc-hot-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member5_committee_hot.vkey \
    --out-file cc5.vote

cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file cc5.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli conway transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/governance_data/cc_member5_committee_hot.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli conway transaction submit --testnet-magic 42 --tx-file vote-tx.signed



////////////////////////////////////////////

DREPS:


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --drep-verification-key-file drep1.vkey \
    --out-file drep1.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file drep1.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file drep1.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed

cardano-cli transaction submit --testnet-magic 42 --tx-file vote-tx.signed


////////////////////////////////////////////



cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --drep-verification-key-file drep2.vkey \
    --out-file drep2.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file drep2.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file drep2.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed

cardano-cli transaction submit --testnet-magic 42 --tx-file vote-tx.signed






/////////////////////////////////////////////



POOLS:


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864" \
    --governance-action-index "0" \
    --cold-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/nodes/node-pool1/cold.vkey \
    --out-file pool1.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file pool1.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/nodes/node-pool1/cold.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli transaction submit --testnet-magic 42 --tx-file vote-tx.signed


/////////////////////////////////////////////


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "aab5f69a028c87b056b931f8bf684aafd4c2c9230993503848fd4983c0634277" \
    --governance-action-index "0" \
    --cold-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/nodes/node-pool2/cold.vkey \
    --out-file pool2.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file pool2.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/nodes/node-pool2/cold.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli transaction submit --testnet-magic 42 --tx-file vote-tx.signed


/////////////////////////////////////////////


cardano-cli conway governance vote create \
    --yes \
    --governance-action-tx-id "aab5f69a028c87b056b931f8bf684aafd4c2c9230993503848fd4983c0634277" \
    --governance-action-index "0" \
    --cold-verification-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/nodes/node-pool3/cold.vkey \
    --out-file pool3.vote


cardano-cli conway transaction build --testnet-magic 42 \
    --tx-in "$(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat payment.addr) \
    --vote-file pool3.vote \
    --witness-override 2 \
    --out-file vote-tx.raw


cardano-cli transaction sign --tx-body-file vote-tx.raw \
    --signing-key-file /home/artur/Downloads/Treasury_Withdrawals/cardano-node-tests/dev_workdir/state-cluster0/nodes/node-pool3/cold.skey \
    --signing-key-file payment.skey \
    --testnet-magic 42 \
    --out-file vote-tx.signed


cardano-cli transaction submit --testnet-magic 42 --tx-file vote-tx.signed



"proposals": [
        {
            "actionId": {
                "govActionIx": 0,
                "txId": "aab5f69a028c87b056b931f8bf684aafd4c2c9230993503848fd4983c0634277"
            },
            "committeeVotes": {
                "keyHash-3c89bfb9cccd2dcec890d3165476efbbb223d5797ea71c69f968aadc": "VoteYes",
                "keyHash-cd6eccb9d76e10927c29501bb076f75132db81ddba622525ab934174": "VoteYes",
                "keyHash-df6d4d95e5634c99b755237485355134559637060f3b97703f507690": "VoteYes",
                "keyHash-e877ce8bc564a4f280e4e48c4debbfdf3135b4f4887286f570642002": "VoteYes",
                "keyHash-fcf6a1501621a8d3a4adafef5261a5edbd93716669d693d894dd1a91": "VoteYes"
            },
            "dRepVotes": {},
            "expiresAfter": 18,
            "proposalProcedure": {
                "anchor": {
                    "dataHash": "931f1d8cdfdc82050bd2baadfe384df8bf99b00e36cb12bfb8795beab3ac7fe5",
                    "url": "https://tinyurl.com/yc74fxx4"
                },
                "deposit": 100000000,
                "govAction": {
                    "contents": [
                        [
                            [
                                {
                                    "credential": {
                                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                                    },
                                    "network": "Testnet"
                                },
                                1234512345
                            ]
                        ],
                        null
                    ],
                    "tag": "TreasuryWithdrawals"
                },
                "returnAddr": {
                    "credential": {
                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                    },
                    "network": "Testnet"
                }
            },
            "proposedIn": 16,
            "stakePoolVotes": {}
        }
    ]
}



dbsync0=# select * from gov_action_proposal;
select * from gov_action_proposal;
 id | tx_id | index | prev_gov_action_proposal |  deposit  | return_address | expiration | voting_anchor_id |        type         |                                                                                    description                                                                                    | param_proposal | ratified_epoch | enacted_epoch | dropped_epoch | expired_epoch 
----+-------+-------+--------------------------+-----------+----------------+------------+------------------+---------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------+---------------+---------------+---------------
  1 |    12 |     0 |                          | 100000000 |             19 |         12 |                2 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"}}, 1234512345]], null]} |                |                |               |            13 |            12
  3 |    14 |     0 |                          | 100000000 |             19 |         19 |                2 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"}}, 1234512345]], null]} |                |                |               |               |              
(2 rows)




BEFORE:

   "proposals": [
        {
            "actionId": {
                "govActionIx": 0,
                "txId": "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864"
            },
            "committeeVotes": {},
            "dRepVotes": {},
            "expiresAfter": 26,
            "proposalProcedure": {
                "anchor": {
                    "dataHash": "931f1d8cdfdc82050bd2baadfe384df8bf99b00e36cb12bfb8795beab3ac7fe5",
                    "url": "https://tinyurl.com/yc74fxx4"
                },
                "deposit": 100000000,
                "govAction": {
                    "contents": [
                        [
                            [
                                {
                                    "credential": {
                                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                                    },
                                    "network": "Testnet"
                                },
                                1234512345
                            ]
                        ],
                        null
                    ],
                    "tag": "TreasuryWithdrawals"
                },
                "returnAddr": {
                    "credential": {
                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                    },
                    "network": "Testnet"
                }
            },
            "proposedIn": 24,
            "stakePoolVotes": {}
        }
    ]
}



AFTER:

    "proposals": [
        {
            "actionId": {
                "govActionIx": 0,
                "txId": "4ec93828b3276a3fbd978e96c2371570d404c0edf035fa030b722fc72a203864"
            },
            "committeeVotes": {
                "keyHash-3c89bfb9cccd2dcec890d3165476efbbb223d5797ea71c69f968aadc": "VoteYes",
                "keyHash-cd6eccb9d76e10927c29501bb076f75132db81ddba622525ab934174": "VoteYes",
                "keyHash-df6d4d95e5634c99b755237485355134559637060f3b97703f507690": "VoteYes",
                "keyHash-e877ce8bc564a4f280e4e48c4debbfdf3135b4f4887286f570642002": "VoteYes",
                "keyHash-fcf6a1501621a8d3a4adafef5261a5edbd93716669d693d894dd1a91": "VoteYes"
            },
            "dRepVotes": {
                "keyHash-2ab2ad3de12ffc6f5699cd56354bd7b42dc15d98ad3f278534d07acb": "VoteYes",
                "keyHash-d6c860496b65a283ab03f25048c081ed547beae6c227b6454a7b94c8": "VoteYes"
            },
            "expiresAfter": 26,
            "proposalProcedure": {
                "anchor": {
                    "dataHash": "931f1d8cdfdc82050bd2baadfe384df8bf99b00e36cb12bfb8795beab3ac7fe5",
                    "url": "https://tinyurl.com/yc74fxx4"
                },
                "deposit": 100000000,
                "govAction": {
                    "contents": [
                        [
                            [
                                {
                                    "credential": {
                                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                                    },
                                    "network": "Testnet"
                                },
                                1234512345
                            ]
                        ],
                        null
                    ],
                    "tag": "TreasuryWithdrawals"
                },
                "returnAddr": {
                    "credential": {
                        "keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"
                    },
                    "network": "Testnet"
                }
            },
            "proposedIn": 24,
            "stakePoolVotes": {}
        }
    ]
}


cardano-cli conway query stake-address-info --address stake_test1upjfk00dpuvpqqsuhpzd26sy2vg5pynx8tjdw2sv4733ceq4lluan --testnet-magic 42
[
    {
        "address": "stake_test1upjfk00dpuvpqqsuhpzd26sy2vg5pynx8tjdw2sv4733ceq4lluan",
        "delegationDeposit": 400000,
        "rewardAccountBalance": 200000000,
        "stakeDelegation": null,
        "voteDelegation": null
    }
]

cardano-cli conway query tip --testnet-magic 42
{
    "block": 2637,
    "epoch": 26,
    "era": "Conway",
    "hash": "ef82d445e56178fe5e3b8915d4242bf3b85dec6e30305af4c6b18b5df00f2710",
    "slot": 26765,
    "slotInEpoch": 765,
    "slotsToEpochEnd": 235,
    "syncProgress": "100.00"
}





dbsync0=# select * from gov_action_proposal;
select * from gov_action_proposal;
 id | tx_id | index | prev_gov_action_proposal |  deposit  | return_address | expiration | voting_anchor_id |        type         |                                                                                    description                                                                                     | param_proposal | ratified_epoch | enacted_epoch | dropped_epoch | expired_epoch 
----+-------+-------+--------------------------+-----------+----------------+------------+------------------+---------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------+---------------+---------------+---------------
  1 |    12 |     0 |                          | 100000000 |             19 |         12 |                2 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"}}, 1234512345]], null]}  |                |                |               |            13 |            12
  3 |    14 |     0 |                          | 100000000 |             19 |         19 |                2 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"}}, 1234512345]], null]}  |                |                |               |            20 |            19
  4 |    22 |     0 |                          | 100000000 |             19 |         27 |                2 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "649b3ded0f1810021cb844d56a0453114092663ae4d72a0cafa31c64"}}, 1234512345]], null]}  |                |                |               |            28 |            27
  8 |    49 |     0 |                          | 100000000 |             35 |         49 |                9 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "807c313097e6ebe409e241962c19d50ae46f5aeca4e7519da2f89df4"}}, 5000000000]], null]}  |                |                |               |            50 |            49
  9 |    49 |     1 |                          | 100000000 |             35 |         49 |               10 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "807c313097e6ebe409e241962c19d50ae46f5aeca4e7519da2f89df4"}}, 5000000001]], null]}  |                |                |               |            50 |            49
 10 |    49 |     2 |                          | 100000000 |             35 |         49 |               11 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "807c313097e6ebe409e241962c19d50ae46f5aeca4e7519da2f89df4"}}, 5000000002]], null]}  |                |                |               |            50 |            49
  5 |    45 |     0 |                          | 100000000 |             35 |         47 |                6 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "d68abaaad705809f2900af32e5f63d98339009370114acc715281aeb"}}, 10000000000]], null]} |                |             45 |            46 |            46 |              
  6 |    45 |     1 |                          | 100000000 |             35 |         47 |                7 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "d68abaaad705809f2900af32e5f63d98339009370114acc715281aeb"}}, 10000000000]], null]} |                |             45 |            46 |            46 |              
  7 |    45 |     2 |                          | 100000000 |             35 |         47 |                8 | TreasuryWithdrawals | {"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "d68abaaad705809f2900af32e5f63d98339009370114acc715281aeb"}}, 10000000000]], null]} |                |             45 |            46 |            46 |              
(9 rows)

dbsync0=# select * from reward_rest;
select * from reward_rest;
 addr_id |      type       |   amount    | spendable_epoch | earned_epoch 
---------+-----------------+-------------+-----------------+--------------
      19 | proposal_refund |   100000000 |              13 |           12
      19 | proposal_refund |   100000000 |              20 |           19
      19 | proposal_refund |   100000000 |              28 |           27
      35 | proposal_refund |   100000000 |              46 |           45
      35 | proposal_refund |   100000000 |              46 |           45
      35 | proposal_refund |   100000000 |              46 |           45
      37 | treasury        | 10000000000 |              46 |           45
      37 | treasury        | 10000000000 |              46 |           45
      37 | treasury        | 10000000000 |              46 |           45
      35 | proposal_refund |   100000000 |              50 |           49
      35 | proposal_refund |   100000000 |              50 |           49
      35 | proposal_refund |   100000000 |              50 |           49
(12 rows)




select * from stake_address where hash_raw = '\xe0d68abaaad705809f2900af32e5f63d98339009370114acc715281aeb';
 id |                           hash_raw                           |                               view                               | script_hash 
----+--------------------------------------------------------------+------------------------------------------------------------------+-------------
 37 | \xe0d68abaaad705809f2900af32e5f63d98339009370114acc715281aeb | stake_test1urtg4w426uzcp8efqzhn9e0k8kvr8yqfxuq3ftx8z55p46ctemuqx | 
(1 row)



cardano-cli conway query stake-address-info --address stake_test1urtg4w426uzcp8efqzhn9e0k8kvr8yqfxuq3ftx8z55p46ctemuqx --testnet-magic 42
[
    {
        "address": "stake_test1urtg4w426uzcp8efqzhn9e0k8kvr8yqfxuq3ftx8z55p46ctemuqx",
        "delegationDeposit": 400000,
        "rewardAccountBalance": 30000000000,
        "stakeDelegation": null,
        "voteDelegation": null
    }
]