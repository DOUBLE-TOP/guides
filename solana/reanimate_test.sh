#!/bin/bash

solana-install init v1.14.23

sudo systemctl stop solana

# sudo rm -rf $HOME/ledger/*

bash -c "cat > $HOME/solana.service<<EOF
[Unit]
Description=Solana TdS node
After=network.target syslog.target
StartLimitIntervalSec=0
[Service]
User=$USER
Type=simple
Restart=always
RestartSec=1
LimitNOFILE=1024000
Environment="SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"
ExecStart=$HOME/.local/share/solana/install/active_release/bin/solana-validator \
--entrypoint entrypoint.testnet.solana.sergo.dev:8001 \
--entrypoint entrypoint.testnet.solana.com:8001 \
--entrypoint entrypoint2.testnet.solana.com:8001 \
--entrypoint entrypoint3.testnet.solana.com:8001 \
--wait-for-supermajority 213932256 \
--expected-shred-version 61807 \
--no-incremental-snapshots \
--expected-bank-hash 4cyHLxMPCJH4pq9v6eVDFBKKNwrVw8ww78yYUSJNDvjU \
--expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
--known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
--wal-recovery-mode skip_any_corrupted_record \
--identity $HOME/validator-keypair.json \
--vote-account $HOME/vote-account-keypair.json \
--ledger $HOME/ledger \
--limit-ledger-size 50000000 \
--dynamic-port-range 8000-8020 \
--log $HOME/solana.log \
--snapshot-interval-slots 500 \
--maximum-local-snapshot-age 500 \
--snapshot-compression none \
--no-port-check \
--rpc-bind-address 127.0.0.1 \
--rpc-port 8899 \
--accounts-db-caching-enabled \
--full-rpc-api
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload

# wget --trust-server-names http://69.197.4.3:6969/snapshot-199641374-njbdgtFvyDqiaCXRsgddu3J5uEtG6zPH81cmArcQSxS.tar.zst -P $HOME/ledger

sudo systemctl restart solana
