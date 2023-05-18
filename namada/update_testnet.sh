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

# function update_code {
#   cd $HOME/namada
#   NEWTAG=v0.13.0
#   git fetch
#   git checkout $NEWTAG
#   make build-release
# }

function update_bin {
  NEWTAG=v0.15.3
  sudo systemctl stop namada
  sudo rm /usr/local/bin/{namada,namadac,namadan,namadaw}
  sudo wget -O /usr/local/bin/namada https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namada
  sudo wget -O /usr/local/bin/namadac https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namadac
  sudo wget -O /usr/local/bin/namadan https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namadan
  sudo wget -O /usr/local/bin/namadaw https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namadaw
  sudo chmod +x /usr/local/bin/{tendermint,namada,namadac,namadan,namadaw}
  sudo systemctl restart namada
}

namada --version

colors
line
logo
line
# update_code
update_bin
line
echo "namada updated to version $NEWTAG"
