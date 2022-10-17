#!/bin/bash

function download_aptos_cli {
  rm -f /usr/local/bin/aptos
  wget -O $HOME/aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.3.2/aptos-cli-0.3.2-Ubuntu-x86_64.zip
  sudo unzip -o aptos-cli -d /usr/local/bin
  sudo chmod +x /usr/local/bin/aptos
}

function add_layout {
  tee $HOME/aptos_testnet/layout.yaml > /dev/null <<EOF
---
root_key: "D04470F43AB6AEAA4EB616B72128881EEF77346F2075FFE68E14BA7DEBD8095E"
users:
 - $aptos_username
chain_id: 47
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
}

function update_files {
  sudo wget -O $HOME/aptos_testnet/docker-compose.yaml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aptos/docker-compose.yaml
  sudo wget -O $HOME/aptos_testnet/genesis.blob https://github.com/aptos-labs/aptos-ait3/raw/main/genesis.blob
  sudo wget -O $HOME/aptos_testnet/waypoint.txt https://raw.githubusercontent.com/aptos-labs/aptos-ait3/main/waypoint.txt
}

function get_envs {
  echo "export operator_addr=`cat $HOME/aptos_testnet/keys/private-keys.yaml | grep "account_address" | awk '{print $2}'`" >> $HOME/.profile

  echo "export pr_key=`cat $HOME/aptos_testnet/keys/private-keys.yaml | grep "account_private_key" | awk '{print $2}' | sed 's/\"//g'`" >> $HOME/.profile
}

docker-compose -f $HOME/aptos_testnet/docker-compose.yaml down -v
download_aptos_cli
add_layout
update_files
get_envs
# docker-compose -f $HOME/aptos_testnet/docker-compose.yaml up -d
echo "обновлено, переходите к следующему пункту гайда"
