#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo cp $HOME/casper-node/target/wasm32-unknown-unknown/release/activate_bid.wasm /opt
sudo chown casper.casper /opt/activate_bid.wasm

CHAIN_NAME=$(curl -s http://127.0.0.1:8888/status | jq -r '.chainspec_name')

sudo -u casper casper-client put-deploy \
--secret-key /etc/casper/validator_keys/secret_key.pem \
--chain-name "$CHAIN_NAME" \
--session-path /opt/activate_bid.wasm \
--payment-amount 300000000 \
--session-arg "validator_public_key:public_key='$(cat /etc/casper/validator_keys/public_key_hex)'"
