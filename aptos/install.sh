#!/bin/bash

function aptos_username {
  if [ ! ${aptos_username} ]; then
  echo "Введите свое имя ноды(придумайте)"
  line
  read aptos_username
  fi
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
}

function install_docker {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash
}

function set_vars {
  echo "export aptos_username=${aptos_username}"  >> ${HOME}/.bash_profile
}

function update_deps {
  sudo apt update
  sudo apt install mc build-essential wget htop curl jq unzip -y
}

function download_aptos_cli {
  rm -f /usr/local/bin/aptos
  wget -O $HOME/aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.3.1/aptos-cli-0.3.1-Ubuntu-x86_64.zip
  sudo unzip -o aptos-cli -d /usr/local/bin
  sudo chmod +x /usr/local/bin/aptos
}

function prepare_config {
  mkdir ${HOME}/aptos_testnet
  wget -qO $HOME/aptos_testnet/docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
  wget -qO $HOME/aptos_testnet/validator.yaml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aptos/validator.yaml
}

function prepare_validator {
  mkdir -p $HOME/aptos_testnet/keys/

  aptos genesis generate-keys --output-dir $HOME/aptos_testnet/keys

  aptos key generate --output-file $HOME/aptos_testnet/keys/root

  aptos genesis set-validator-configuration \
    --owner-public-identity-file  $HOME/aptos_testnet/keys/public-keys.yaml --local-repository-dir $HOME/aptos_testnet \
    --username "$aptos_username" \
    --validator-host `wget -qO- eth0.me`:6180 \
    --full-node-host `wget -qO- eth0.me`:6182 \
    --stake-amount 100000000000000

    # aptos genesis generate-layout-template --output-file ~/aptos_testnet/layout.yaml


  tee $HOME/aptos_testnet/layout.yaml > /dev/null <<EOF
---
root_key: "D04470F43AB6AEAA4EB616B72128881EEF77346F2075FFE68E14BA7DEBD8095E"
users:
 - $aptos_username
chain_id: 43
allow_new_validators: false
epoch_duration_secs: 7200
is_test: true
min_stake: 100000000000000
min_voting_threshold: 100000000000000
max_stake: 100000000000000000
recurring_lockup_duration_secs: 86400
required_proposer_stake: 100000000000000
rewards_apy_percentage: 10
voting_duration_secs: 43200
voting_power_increase_limit: 20
EOF

  wget -O $HOME/aptos_testnet/framework.mrb https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.3.0/framework.mrb

  aptos genesis generate-genesis --local-repository-dir $HOME/aptos_testnet --output-dir $HOME/aptos_testnet
}

function up_validator {
  docker-compose -f ${HOME}/aptos_testnet/docker-compose.yaml pull
  docker-compose -f ${HOME}/aptos_testnet/docker-compose.yaml up -d
}
function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

colors
line
logo
line
aptos_username
set_vars
line
install_ufw
install_docker
update_deps
line
download_aptos_cli
prepare_config
prepare_validator
line
up_validator
line
echo "Готово"
