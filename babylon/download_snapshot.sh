#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  YELLOW="\e[33m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function output {
  echo -e "${YELLOW}$1${NORMAL}"
}

function source_profile {
    source $HOME/.profile
    sleep 1
}

function unsafe-reset-all {
    babylond tendermint unsafe-reset-all --keep-addr-book
}

function download_snapshot {
    curl -L https://snapshots.kjnodes.com/babylon-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.babylond
    [[ -f $HOME/.babylond/data/upgrade-info.json ]] && cp $HOME/.babylond/data/upgrade-info.json $HOME/.babylond/cosmovisor/genesis/upgrade-info.json
}

function restart_babylon {
    sudo systemctl restart babylon
}

function main {
    colors
    line
    logo
    line
    output "Prepare bin and clean old data...."
    line
    output "Download snapshot...."
    download_snapshot
    line
    output "Restart babylon...."
    restart_babylon
    line
    output "Done!"    
}

main