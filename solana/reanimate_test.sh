#!/bin/bash

solana-install init v1.14.7

sudo systemctl stop solana

sudo rm -rf $HOME/ledger/*

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
--entrypoint tsolv.im-0.net:8000 \
--entrypoint entrypoint.testnet.solana.com:8001 \
--entrypoint entrypoint2.testnet.solana.com:8001 \
--entrypoint entrypoint3.testnet.solana.com:8001 \
--expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
--known-validator eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ \
--known-validator 9v7E6oEm1V86hjTubtBon7cRYPvQriWZKHZEX6j92Po4 \
--known-validator FnpP7TK6F2hZFVnqSUJagZefwRJ4fmnb1StS1NokpLZM \
--known-validator J7v9ndmcoBuo9to2MnHegLnBkC9x3SAVbQBJo5MMJrN1 \
--wait-for-supermajority 160991176 \
--no-snapshot-fetch \
--no-genesis-fetch \
--expected-bank-hash GfNNxK4wS51NDWos2DQoLKU2ECiMEbFMPRw7bpDi9BoY \
--expected-shred-version 4711 \
--only-known-rpc \
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

# source $HOME/solana-snapshot-finder/venv/bin/activate
#
# python3 $HOME/solana-snapshot-finder/snapshot-finder.py --snapshot_path $HOME/ledger -r https://api.testnet.solana.com

wget -O $HOME/ledger/snapshot-160991176-5GMY4MtGzDnXYq9AVssRBxVyRj6YVRMjxfjZtqVBeP97.tar.zst http://tsolv.im-0.net:13899/snapshot-160991176-5GMY4MtGzDnXYq9AVssRBxVyRj6YVRMjxfjZtqVBeP97.tar.zst

wget -O $HOME/ledger/genesis.tar.bz2 http://api.testnet.solana.com/genesis.tar.bz2

sudo systemctl restart solana
