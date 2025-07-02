#!/bin/bash

agave-install init v2.3.2

sudo systemctl stop solana

sudo rm -rf $HOME/ledger/*

bash -c "cat > $HOME/solana.service<<EOF
[Unit]
Description=Solana TdS node
After=network.target syslog.target
StartLimitIntervalSec=0
[Service]
User=root
Type=simple
Restart=always
RestartSec=1
LimitNOFILE=1024000
Environment=SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea
ExecStart=/root/.local/share/solana/install/active_release/bin/agave-validator \
--entrypoint entrypoint.testnet.solana.sergo.dev:8001 \
--entrypoint entrypoint.testnet.solana.com:8001 \
--entrypoint entrypoint2.testnet.solana.com:8001 \
--entrypoint entrypoint3.testnet.solana.com:8001 \
--expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
--wal-recovery-mode skip_any_corrupted_record \
--identity /root/validator-keypair.json \
--vote-account /root/vote-account-keypair.json \
--ledger /root/ledger \
--limit-ledger-size 50000000 \
--dynamic-port-range 8000-8020 \
--log /root/solana.log \
--snapshot-interval-slots 500 \
--maximum-local-snapshot-age 500 \
--no-port-check \
--rpc-bind-address 127.0.0.1 \
--rpc-port 8899 \
--full-rpc-api \
--known-validator FT9QgTVo375TgDAQusTgpsfXqTosCJLfrBpoVdcbnhtS \
--known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
--wait-for-supermajority 343175553 \
--expected-shred-version 9065 \
--expected-bank-hash 4oMrSXsLTiCc1X7S27kxSfGVraTCZoZ7YTy2skEB9bPk 
ExecReload=/bin/kill -s HUP 
ExecStop=/bin/kill -s QUIT 
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload

sudo systemctl restart solana
