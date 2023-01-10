#!/bin/bash

function logo {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh)
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function update_code {
  cd $HOME/namada
  NEWTAG=v0.13.0
  git fetch
  git checkout $NEWTAG
  make build-release
}

function update_bin {
  sudo systemctl stop namada
  sudo rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw
  sudo cp "$HOME/namada/target/release/namada" /usr/local/bin/namada
  sudo cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac
  sudo cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan
  sudo cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
  sudo systemctl restart namada
}

namada --version

colors
line
logo
line
update_code
update_bin
line
echo "namada updated to version $NEWTAG"
