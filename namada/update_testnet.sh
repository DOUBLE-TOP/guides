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
  NEWTAG=v0.13.0
  sudo systemctl stop namada
  sudo rm /usr/local/bin/{namada,namadac,namadan,namadaw}
  sudo wget -O https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namada /usr/local/bin/namada
  sudo wget -O https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namadac /usr/local/bin/namadac
  sudo wget -O https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namadan /usr/local/bin/namadan
  sudo wget -O https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NEWTAG/namadaw /usr/local/bin/namadaw
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
