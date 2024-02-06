#!/bin/bash

solana-install init v1.17.20

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
ExecStart=$HOME/.local/share/solana/install/active_release/bin/solana-validator \
--entrypoint entrypoint.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
--known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
--known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
--known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
--known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
--only-known-rpc \
--no-snapshot-fetch \
--no-genesis-fetch \
--wait-for-supermajority 246464040 \
--expected-shred-version 50093 \
--expected-bank-hash 2QEvYhBgeWPJbC84fMTTK9NgntqiUAWiBEBf21rtTmng \
--expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
--wal-recovery-mode skip_any_corrupted_record \
--identity $HOME/mainnet-validator-keypair.json \
--vote-account $HOME/vote-account-keypair.json \
--ledger $HOME/ledger \
--limit-ledger-size 50000000 \
--dynamic-port-range 8000-8020 \
--log $HOME/solana.log \
--full-snapshot-interval-slots 25000 \
--incremental-snapshot-interval-slots 500 \
--maximum-full-snapshots-to-retain 1 \
--maximum-incremental-snapshots-to-retain 2 \
--maximum-local-snapshot-age 2500 \
--rpc-port 8899 \
--full-rpc-api \
--private-rpc
ExecReload=/bin/kill -s HUP 
ExecStop=/bin/kill -s QUIT 
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload

#source $HOME/solana-snapshot-finder/venv/bin/activate

#python3 $HOME/solana-snapshot-finder/snapshot-finder.py --snapshot_path $HOME/ledger

wget -O $HOME/ledger/snapshot-246464040-9kmqknr1D8pQXn92dWMDWvfZ9nwzgxRQ6JnbUrG3KN4F.tar.zst wget https://storage.googleapis.com/jito-mainnet/snapshot-246464040-9kmqknr1D8pQXn92dWMDWvfZ9nwzgxRQ6JnbUrG3KN4F.tar.zst

sudo systemctl restart solana