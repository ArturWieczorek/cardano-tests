**OS:**
Your OS: Linux Mint 20.2 Cinnamon
Linux Kernel: 5.4.0-90-generic

**Machine Specs:**
Processor: AMD Ryzen 9 3900X 12-Core Processor × 12
RAM: 32 GB



**Versions**
The `db-sync` version : `tag: 12.0.0-pre3`
```
cardano-db-sync --version
cardano-db-sync 12.0.0 - linux-x86_64 - ghc-8.10
git revision 6e594658780bcd21b94808861177db1284aa168d
```

The `cardano-node` version:

```
cardano-node --version
cardano-node 1.31.0 - linux-x86_64 - ghc-8.10
git rev 2cbe363874d0261bc62f52185cf23ed492cf4859
```

PostgreSQL version: 12.8

**Build/Install Method**
The method you use to build or install `cardano-db-sync`:
`cardano-db-sync` and `smash` were built with `nix` using official instruction docs.

**Run method**
The method you used to run `cardano-db-sync` (eg Nix/Docker/systemd/none):

```
PGPASSFILE=config/pgpass-testnet db-sync-node/bin/cardano-db-sync --config config/testnet-config.yaml --socket-path ../cardano-node/state-node-testnet/node.socket --schema-dir schema/ --state-dir ledger-state/testnet_new_smash
```

```
PGPASSFILE=config/pgpass-testnet ./cardano-smash-server_      --config config/testnet-config.yaml      --port 3101      --admins admins.txt
[smash-server:Info:6] [2021-10-28 13:47:07.72 UTC] SMASH listening on port 3101
```


**Additional context**
Discovered during testing [name]

**Problem Report**
