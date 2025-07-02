#!/bin/bash

sudo systemctl stop firedancer

sudo rm -rf /firedancer/ledger/*

bash -c "cat > /firedancer/firedancer-config.toml<<EOF
user = "firedancer"
dynamic_port_range = "8900-9000"

[gossip]
    entrypoints = [
      "entrypoint.testnet.solana.com:8001",
      "entrypoint2.testnet.solana.com:8001",
      "entrypoint3.testnet.solana.com:8001",
    ]

[ledger]
    limit_size = 100_000_000
    path = "/home/firedancer/ledger/"
    accounts_path = "/home/firedancer/ledger/accounts/"

[snapshots]
    incremental_snapshots = true
    full_snapshot_interval_slots = 25000
    incremental_snapshot_interval_slots = 500
    maximum_full_snapshots_to_retain = 1
    maximum_incremental_snapshots_to_retain = 2
    path = "/home/firedancer/ledger/snapshots/"
    incremental_path = "/home/firedancer/ledger/snapshots/incremental/"
    minimum_snapshot_download_speed = 10485760

[log]
    path = "/home/firedancer/firedancer.log"
    colorize = "auto"
    level_logfile = "INFO"
    level_stderr = "NOTICE"
    level_flush = "WARNING"

[consensus]
    identity_path = "/home/firedancer/validator-keypair.json"
    vote_account_path = "/home/firedancer/vote-account-keypair.json"

    snapshot_fetch = true
    genesis_fetch = true
    poh_speed_test = false

    known_validators = [
        "5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on",
        "dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs",
        "Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN",
        "eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ",
        "9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv",
    ]
    wait_for_supermajority_at_slot = 343175553
    expected_bank_hash = "4oMrSXsLTiCc1X7S27kxSfGVraTCZoZ7YTy2skEB9bPk"
    expected_shred_version = 9065

[rpc]
    port = 8899
    full_api = true
    private = true
    only_known = true
    transaction_history = true

[reporting]
    solana_metrics_config = "host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"

[layout]
    affinity = "auto"
    agave_affinity = "auto"
    verify_tile_count = 1
    bank_tile_count = 1

[tiles]
    [tiles.quic]
        max_concurrent_connections = 131072
        max_concurrent_handshakes = 4096
    [tiles.shred]
        max_pending_shred_sets = 512
[tiles.bundle]
    enabled = true
    url = "https://testnet.block-engine.jito.wtf"
    tip_distribution_program_addr = "F2Zu7QZiTYUhPd7u9ukRVwxh7B71oA3NMJcHuCHc29P2"
    tip_payment_program_addr = "GJHtFqM9agxPmkeKjHny6qiRKrXZALvvFGiKf11QE7hy"
    tip_distribution_authority = "GZctHpWXmsZC1YHACTGGcHhYxjdRqQvTpYkb9LMvxDib"
    commission_bps = 10000
EOF"

sudo systemctl daemon-reload

sudo systemctl restart solana
