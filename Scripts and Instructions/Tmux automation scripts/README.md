# Tmux automation scripts

Scripts for spinning up:

- `cardano-node-tests` framework with one command

</br>

Directory structure:


```sh
/Playground/test_framework$ ll
total 24
drwxrwxr-x  5 artur artur 4096 Dec 10 16:10 ./
drwxrwxr-x  4 artur artur 4096 Dec  6 00:08 ../
drwxrwxr-x 23 artur artur 4096 Dec  5 22:36 cardano-node/        <--- will be downloaded by script
drwxrwxr-x 16 artur artur 4096 Dec  9 22:45 cardano-node-tests/  <--- will be downloaded by script
drwxr-xr-x  3 artur artur 4096 Dec  9 22:53 postgres-qa/
-rw-rw-r--  1 artur artur 3396 Dec 10 16:10 .tmuxinator.yml
```

</br>

- blockchain networks with one command

</br>

Directory structure:

```sh
/home/artur/Playground/blockchain_networks

drwxrwxr-x 4 artur artur 4096 Dec  5 17:54 Base_Projects/
drwxrwxr-x 2 artur artur 4096 Dec 10 16:16 mainnet/
drwxrwxr-x 2 artur artur 4096 Dec 10 16:16 shelley_qa/
drwxrwxr-x 2 artur artur 4096 Dec 10 16:16 testnet/
-rw-rw-r-- 1 artur artur 3338 Dec  9 22:19 .tmuxinator.yml
```

</br>

# Bash aliases

Add following Bash aliases for starting blockchain networks and test framework with one command:

```sh
alias start_sqa='cd /home/artur/Playground/blockchain_networks/shelley_qa; tmuxinator start shelley_qa'
alias start_testnet='cd /home/artur/Playground/blockchain_networks/testnet; tmuxinator start testnet'
alias start_mainnet='cd /home/artur/Playground/blockchain_networks/mainnet; tmuxinator start mainnet'
alias start_cluster='cd /home/artur/Playground/test_framework;tmuxinator start test_framework'
```
