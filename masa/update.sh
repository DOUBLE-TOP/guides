#!/bin/bash

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

function backup_keys {
  cd $HOME/masa-node-v1.0/
  mkdir -p $HOME/masa-bk/
  cp data/geth/nodekey $HOME/masa-bk/
}

function remove_old_db {
  rm -rf $HOME/masa-node-v1.0/data
}

function init_db_recover_keys {
  cd $HOME/masa-node-v1.0/
  geth --datadir data init ./network/testnet/genesis.json
  cp $HOME/masa-bk/nodekey data/geth/
}

function bin_update {
  cd $HOME/masa-node-v1.0/src
  git fetch
  git checkout v1.04
  make all
  cd $HOME/masa-node-v1.0/src/build/bin
  sudo cp * /usr/local/bin
}

colors
line
logo
line
echo -e "${RED}Update starting${NORMAL}"
line
backup_keys
sudo systemctl stop masad
remove_old_db
bin_update
init_db_recover_keys
sudo systemctl restart masad
line
echo -e "${RED}Update finished${NORMAL}"
line
