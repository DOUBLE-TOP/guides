#!/bin/bash

function download_aptos_cli {
  rm -f /usr/local/bin/aptos
  wget -O $HOME/aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-0.2.0/aptos-cli-0.2.0-Ubuntu-x86_64.zip
  sudo unzip -o aptos-cli -d /usr/local/bin
  sudo chmod +x /usr/local/bin/aptos
}

function add_layout {
  tee ${HOME}/aptos_testnet/layout.yaml > /dev/null <<EOF
---
root_key: "F22409A93D1CD12D2FC92B5F8EB84CDCD24C348E32B3E7A720F3D2E288E63394"
users:
  - ${aptos_username}
chain_id: 40
min_stake: 0
max_stake: 100000
min_lockup_duration_secs: 0
max_lockup_duration_secs: 2592000
epoch_duration_secs: 86400
initial_lockup_timestamp: 1656615600
min_price_per_gas_unit: 1
allow_new_validators: true
EOF
}

function download_framework {
  wget -qO ${HOME}/aptos_testnet/framework.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
  unzip -o ${HOME}/aptos_testnet/framework.zip -d ${HOME}/aptos_testnet/
  rm ${HOME}/aptos_testnet/framework.zip
}

function configure_validator {
  aptos genesis set-validator-configuration \
  --keys-dir ${HOME}/aptos_testnet --local-repository-dir ${HOME}/aptos_testnet \
  --username $aptos_username \
  --validator-host `wget -qO- eth0.me`:6180 \
  --full-node-host `wget -qO- eth0.me`:6182
}

source $HOME/.bash_profile
cd $HOME/$WORKSPACE
docker-compose pull
docker-compose down
download_aptos_cli
add_layout
download_framework
configure_validator
docker-compose up -d
