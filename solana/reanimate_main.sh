#!/bin/bash

solana-install init v1.13.6

sudo systemctl stop solana

sudo rm -rf $HOME/ledger/*

bash -c "cat > $HOME/solana.service<<EOF
[Unit]
Description=Solana MB Node
After=network.target syslog.target
StartLimitIntervalSec=0
[Service]
User=$USER
Type=simple
Restart=always
RestartSec=1
LimitNOFILE=2024000
Environment="SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password"
ExecStart=$HOME/.local/share/solana/install/active_release/bin/solana-validator \
--expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
--no-snapshot-fetch \
--wait-for-supermajority 179526403 \
--expected-shred-version 56177 \
--expected-bank-hash 69p75jzzT1P2vJwVn3wbTVutxHDcWKAgcbjqXvwCVUDE \
--known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
--known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
--known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
--known-validator C1ocKDYMCm2ooWptMMnpd5VEB2Nx4UMJgRuYofysyzcA \
--known-validator GwHH8ciFhR8vejWCqmg8FWZUCNtubPY2esALvy5tBvji \
--known-validator 6WgdYhhGE53WrZ7ywJA15hBVkw7CRbQ8yDBBTwmBtAHN \
--known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
--entrypoint 3.15.228.179:11000 \
--entrypoint 34.148.228.133:11000 \
--entrypoint 63.251.232.254:21610 \
--entrypoint entrypoint.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
--only-known-rpc \
--wal-recovery-mode skip_any_corrupted_record \
--identity $HOME/mainnet-validator-keypair.json \
--vote-account $HOME/vote-account-keypair.json \
--ledger $HOME/ledger \
--limit-ledger-size 50000000 \
--dynamic-port-range 8000-8020 \
--log $HOME/solana.log \
--full-snapshot-interval-slots 25000 \
--incremental-snapshot-interval-slots 500 \
--maximum-full-snapshots-to-retain 4 \
--maximum-incremental-snapshots-to-retain 20 \
--maximum-local-snapshot-age 3000 \
--full-rpc-api \
--private-rpc \
--rpc-port 8899 
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload

wget -O $HOME/ledger/snapshot-179526403-FUdrVxEUnbp4AzZ5qNPgYB3viRQEGo2n1xq5n382Y8sC.tar.zst wget https://d1fe19ei6b1nmi.cloudfront.net/snapshot-179526403-FUdrVxEUnbp4AzZ5qNPgYB3viRQEGo2n1xq5n382Y8sC.tar.zst

sudo systemctl restart solana