# db-sync-tests
Test scripts for setup and automated checks for db-sync


Setup:

Create directory and copy contents of this repository into it.

Enter that root directory and run from it:


1)node.sh -n network_name (with underscores for `shelley_qa`, `mary_qa`)

script to create `cardano-node` directory and download latest binaries for node and cli there, config for specified network and then run node.


2)db.sh -n network-name (without underscores for `shelley-qa`, `mary-qa`)

script to create `cardano-db-sync` with cloned code that will be built with nix for both, `db-sync` and `db-sync-extended`, configs for all networks will be created and then `db-sync-extended` will be started.

Directory structure:

ROOT_DIR$ ls- l
drwxrwxr-x  8 artur artur  4096 Feb 11 02:02 ./
drwxr-xr-x 16 artur artur  4096 Feb  9 14:49 ../
drwxr-xr-x 17 artur artur  4096 Feb  9 11:18 cardano-db-sync/ <-- created by `db.sh`
drwxr-xr-x  5 artur artur  4096 Feb 10 23:39 cardano-node/  <-- created by `node.sh`
-rwxrwxr-x  1 artur artur  4530 Feb 10 23:51 create-addresses.sh*
-rwxr-xr-x  1 artur artur  6182 Feb  9 14:00 db.sh*
-rwxrwxr-x  1 artur artur  1662 Feb  8 19:59 download-node-configs.sh*
-rwxrwxr-x  1 artur artur  2134 Feb  9 19:37 faucet.sh*
drwx------  2 artur artur  4096 Jul 14  2020 metadata_files/
-rwxr-xr-x  1 artur artur  7109 Feb  9 14:01 node.sh*
-rwxrwxr-x  1 artur artur 26348 Feb 11 02:02 run-txs.sh*

3) Once you got node and db-sync running, you can create addresses on the specified network by using `create-addresses.sh` script.

./create-addresses.sh -n shelley_qa

Sript will create 4 key-pairs, payment and stake addresses:

```bash
Created following addresses inside /media/artur/Projects/CARDANO-STACK/cardano-node/keys: 
total 104
-rw------- 1 artur artur   63 Feb 11 00:51 byron-payment.addr
-rw------- 1 artur artur  376 Feb 11 00:51 byron-payment.skey
-rw------- 1 artur artur  258 Feb 11 00:51 byron-payment.vkey
-rw------- 1 artur artur  108 Feb 11 00:51 extended-payment.addr
-rw------- 1 artur artur  386 Feb 11 00:51 extended-payment.skey
-rw------- 1 artur artur  268 Feb 11 00:51 extended-payment.vkey
drwx------ 2 artur artur 4096 Jul 14  2020 metadata_files
-rw------- 1 artur artur  108 Feb 11 00:51 payment2.addr
-rw------- 1 artur artur  180 Feb 11 00:51 payment2.skey
-rw------- 1 artur artur  190 Feb 11 00:51 payment2.vkey
-rw------- 1 artur artur  108 Feb 11 00:51 payment.addr
-rw------- 1 artur artur  180 Feb 11 00:51 payment.skey
-rw------- 1 artur artur  190 Feb 11 00:51 payment.vkey
-rw------- 1 artur artur   64 Feb 11 00:51 stake2.addr
-rw------- 1 artur artur  176 Feb 11 00:51 stake2.skey
-rw------- 1 artur artur  186 Feb 11 00:51 stake2.vkey
-rw------- 1 artur artur   64 Feb 11 00:51 stake3.addr
-rw------- 1 artur artur  176 Feb 11 00:51 stake3.skey
-rw------- 1 artur artur  186 Feb 11 00:51 stake3.vkey
-rw------- 1 artur artur   64 Feb 11 00:51 stake4.addr
-rw------- 1 artur artur  176 Feb 11 00:51 stake4.skey
-rw------- 1 artur artur  186 Feb 11 00:51 stake4.vkey
-rw------- 1 artur artur   64 Feb 11 00:51 stake.addr
-rw------- 1 artur artur  176 Feb 11 00:51 stake.skey
-rw------- 1 artur artur  186 Feb 11 00:51 stake.vkey
drwxr-xr-x 2 artur artur 4096 Feb  9 23:17 txs

Regular Payment addresses --> payment.addr:
addr_test1qqeztymwmdvr4krcpajn4stqeth5s9m6rra6yhpgqejg5tm9lpyh49rm0esz68x7h24ac6y9xs8e48hznj0wy6zaw9rqrt6q0a

Regular Payment addresses 2 --> payment2.addr:
addr_test1qqxan7p0kufr45zw4nptn3cj7psmvfzt4w5guzgwpcnvm9l8px3k4lv5wfvxq88saw80998zq3cn9ecgg9q5erqeur3qv96wmu

Extended Payment addresses --> extended-payment.addr:
addr_test1qq3umypep0dsxga7qgqme65rjwmclj63weav4ay52pfhf09d8ejaeymasd4e9zr275j0z7k426gf43xn8y4lfgguwa5sdw5vkq

Byron Payment addresses --> byron-payment.addr:
FHnt4NL7yPY5RRWfP4W6HBP6XMjDEXvGaB5K1cTqupjL6TCe2T5BNkBRnYdjT59

Stake 1 address associated with Regular Payment addresses --> stake.addr :
stake_test1upjlsjt6j3ahucpdrn0t427udzzngru6nm3fe8hzdpwhz3slyxc3t

Stake 2 address associated with Extended Payment addresses --> stake2.addr :
stake_test1uzknuewujd7cx6uj3p402f830t24dyy6cnfnj2l55yw8w6g7nuz3y

Stake 3 address associated with Byron Payment addresses --> stake3.addr :
stake_test1uzp69fqvj0kkz6804m37gww2n4t0r7vdx4tk6c2pvvf5plswre0pl


Stake 4 address associated with Byron Payment addresses --> stake3.addr :
stake_test1urnsngm2lk28ykrqrncwhrhjjn3qgufjuuyyzs2v3sv7pcsqz3wuh
```


4) ... and then request funds for specified network with faucet by using `faucet.sh` script.

./faucet.sh -n shelley-qa

WARNING: By default faucet will transfer all funds to regular payment addresses --> payment.addr, which was created by `create-addresses.sh` script.

If you want to use different address you need to specify it by using `-a` argument:

./faucet.sh -n shelley-qa -a addr_test1qzswfwun0k6yvdln9au69h00zwlc50hs2zkn20s3wh5p69gq79jkfepw3mdgpt9ml42yvdg50538yqsxl39nsts7gvws9sygmw









