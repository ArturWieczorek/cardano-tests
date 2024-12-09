cardano-cli query tip --testnet-magic 42


cardano-cli query utxo --address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
33f578c9d6b45e1ec28380d754987ffee7f46c4775a95d796df8d7b8a38f5ea5     3        10121999997244683 lovelace + TxOutDatumNone



cardano-cli transaction build \
--tx-in 33f578c9d6b45e1ec28380d754987ffee7f46c4775a95d796df8d7b8a38f5ea5#3 \
--tx-out $(cat payment.addr)+2000000000000 \
--change-address $(cat dev_workdir/state-cluster0/shelley/genesis-utxo.addr) \
--out-file tx.raw \
--witness-override 2 \
--testnet-magic 42 \
--conway-era
where payment.addr is the Shelley address created manually by the user and --witness-override 2 is used because of this issue.

Sign tx:

cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file dev_workdir/state-cluster0/shelley/genesis-utxo.skey \
--testnet-magic 42 \
--out-file tx.signed
Submit tx:

cardano-cli transaction submit --tx-file tx.signed  --testnet-magic 42
Transaction successfully submitted.


cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
0806739019a129475b0f373de01f95e987b0ea6a62cf9d44e195be9bea85f901     0        2000000000000 lovelace + TxOutDatumNone




cardano-cli conway stake-address registration-certificate \
--stake-verification-key-file stake.vkey \
--key-reg-deposit-amt 400000 \
--out-file registration.cert

- Build the transaction:

cardano-cli conway transaction build \
--testnet-magic 42 \
--witness-override 2 \
--tx-in $(cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 42 --out-file  /dev/stdout | jq -r 'keys[0]') \
--change-address $(cat payment.addr) \
--certificate-file registration.cert \
--out-file tx.raw



Submit the certificate to the chain

- Sign the transaction:

cardano-cli conway transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file stake.skey \
--testnet-magic 42 \
--out-file tx.signed


- Submit the transaction:

cardano-cli conway transaction submit \
--testnet-magic 42 \
--tx-file tx.signed




cardano-cli conway governance action create-info --testnet \
  --governance-action-deposit $(cardano-cli conway query gov-state --testnet-magic 42 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file stake.vkey \
  --anchor-url  https://tinyurl.com/yc74fxx4 \
  --anchor-data-hash 931f1d8cdfdc82050bd2baadfe384df8bf99b00e36cb12bfb8795beab3ac7fe5 \
  --out-file info.action


  cardano-cli conway transaction build \
  --testnet-magic 42 \
  --tx-in "$(cardano-cli query utxo --address "$(cat payment.addr)" --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
  --change-address $(cat payment.addr) \
  --proposal-file info.action \
  --proposal-file info2.action \
  --proposal-file info3.action \
  --out-file tx.raw

  cardano-cli conway transaction sign \
  --testnet-magic 42 \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --out-file tx.signed


  cardano-cli conway transaction submit \
  --testnet-magic 42 \
  --tx-file tx.signed