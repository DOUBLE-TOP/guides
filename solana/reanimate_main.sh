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
--no-snapshot-fetch \
--wait-for-supermajority 179526408 \
--expected-shred-version 12743 \
--expected-bank-hash JCfD7vqjQWKV8Vusx7degWczh55WkQ2cEifGTzCkXdKk \
--known-validator CMPSSdrTnRQBiBGTyFpdCc3VMNuLWYWaSkE8Zh5z6gbd \
--known-validator 6WgdYhhGE53WrZ7ywJA15hBVkw7CRbQ8yDBBTwmBtAHN \
--known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
--known-validator GwHH8ciFhR8vejWCqmg8FWZUCNtubPY2esALvy5tBvji \
--known-validator Ninja1spj6n9t5hVYgF3PdnYz2PLnkt7rvaw3firmjs \
--known-validator PUmpKiNnSVAZ3w4KaFX6jKSjXUNHFShGkXbERo54xjb \
--known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
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

wget -O $HOME/ledger/snapshot-179526408-9kUTC2pYALrYD8rb93E1mY2vG4QG8jCX132Z4CEhBHgJ.tar.zst wget https://dn4xk96mcxun5.cloudfront.net/snapshot-179526408-9kUTC2pYALrYD8rb93E1mY2vG4QG8jCX132Z4CEhBHgJ.tar.zst

sudo systemctl restart solana