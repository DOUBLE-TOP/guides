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
--wait-for-supermajority 161660256 \
--expected-shred-version 6995 \
--entrypoint entrypoint.testnet.solana.sergo.dev:8001 \
--entrypoint tsolv.im-0.net:8000 \
--entrypoint entrypoint.testnet.solana.com:8001 \
--entrypoint entrypoint2.testnet.solana.com:8001 \
--entrypoint entrypoint3.testnet.solana.com:8001 \
--expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
--expected-bank-hash GjU2DYkVVcd4LD3Yew1xSL8XibvVnhVse2U6b5JdNDhN \
--known-validator eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ \
--known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
--known-validator td2GGWDsCJ6LvjN89oLJvmrDwE14neNrbqQ9s3tVkPy \
--known-validator td3n5NGhP7JKWrL638gzau3NY7mF4K3ztZww3GkpywJ  \
--known-validator FnpP7TK6F2hZFVnqSUJagZefwRJ4fmnb1StS1NokpLZM \
--known-validator BFquPCAYdjN9QyLVfuGrQdJTF9Ct7Z85FDxhFeLcpFqR \
--no-snapshot-fetch \
--no-genesis-fetch \
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

wget -O $HOME/ledger/snapshot-161660256-6makAMJ9P4eVnFLUVTrn8zY5N2YWxSXDRGutL7caR4uy.tar.zst http://tsolv.im-0.net:13899/snapshot-161660256-6makAMJ9P4eVnFLUVTrn8zY5N2YWxSXDRGutL7caR4uy.tar.zst

wget -O $HOME/ledger/genesis.tar.bz2  wget http://api.testnet.solana.com/genesis.tar.bz2

sudo systemctl restart solana
