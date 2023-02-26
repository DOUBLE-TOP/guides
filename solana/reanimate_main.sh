#!/bin/bash

solana-install init v1.13.6

sudo systemctl stop solana

sudo rm -rf $HOME/ledger/*

bash -c "cat > /etc/systemd/system/solana.service<<EOF
[Unit]
Description=Solana MB Node
After=network.target syslog.target
StartLimitIntervalSec=0
[Service]
User=root
Type=simple
Restart=always
RestartSec=1
LimitNOFILE=2048000
Environment=SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password
ExecStart=/root/.local/share/solana/install/active_release/bin/solana-validator \
--entrypoint 195.14.6.36:8001 \
--entrypoint 198.244.229.6:8001 \
--entrypoint 147.28.246.5:8001 \
--entrypoint 147.28.151.175:8001 \
--entrypoint 147.75.32.159:8001 \
--entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
--known-validator GjbUdcvguSNUnEeiTWa8f6wC1r1szUtUwKiJCp4oxjFX \
--known-validator Cpcjz8kcLuxZLeTAxyKtCy1dtBb5kvYx35L1NBdmYKa7 \
--known-validator AhWZi767Wo6sDWhXwS8oftvVWhvZj6FEa3175CBJ7Mbj \
--known-validator 4z6YgEYt5U594UYfWh5dgYWEzpZLBqqfW9uQC7imzjne \
--known-validator EBk1bP8LUmoWBHbaBQcwo7AiPtz6dw4yfFb5di8idzny \
--known-validator Ch92wHj5wYDAXYT5BRgo3zwgeg5u6eLfiqZqbpw6Rpn5 \
--no-snapshot-fetch \
--expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
--wal-recovery-mode skip_any_corrupted_record \
--identity /root/mainnet-validator-keypair.json \
--vote-account /root/vote-account-keypair.json \
--ledger /root/ledger \
--limit-ledger-size 50000000 \
--dynamic-port-range 9030-9050 \
--log /root/solana.log \
--full-snapshot-interval-slots 25000 \
--incremental-snapshot-interval-slots 500 \
--rpc-port 8899 \
--full-rpc-api \
--private-rpc
ExecReload=/bin/kill -s HUP 
ExecStop=/bin/kill -s QUIT 
[Install]
WantedBy=multi-user.target

EOF"

sudo systemctl daemon-reload

# wget -O $HOME/ledger/snapshot-179526403-FUdrVxEUnbp4AzZ5qNPgYB3viRQEGo2n1xq5n382Y8sC.tar.zst https://d1fe19ei6b1nmi.cloudfront.net/snapshot-179526403-FUdrVxEUnbp4AzZ5qNPgYB3viRQEGo2n1xq5n382Y8sC.tar.zst

sudo systemctl restart solana