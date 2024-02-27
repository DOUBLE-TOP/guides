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

function output_error {
  echo -e "${RED}$1${NORMAL}"
}

function output_normal {
  echo -e "${GREEN}$1${NORMAL}"
}

function request_password() {
    if [ -z "$DUSK_PASS" ]; then
        read -sp "password: " DUSK_PASS
        echo
        export DUSK_PASS
    fi
}

function itn_installer() {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dusk/itn-installer.sh)
}

function prepare_files() {
  echo DUSK_CONSENSUS_KEYS_PASS=$DUSK_PASS > /opt/dusk/services/dusk.conf
  rusk-wallet --password $DUSK_PASS create --seed-file /opt/dusk/seed.txt
  rusk-wallet --password $DUSK_PASS export -d /opt/dusk/conf -n consensus.keys
}

function start_dusk {
  sudo systemctl daemon-reload
  sudo systemctl enable rusk
  sudo service rusk start
}

function main {
  colors
  line
  logo
  line
  output_error "Enter your password to continue:"
  request_password
  line
  output "Installing Dusk Network..."
  line
  itn_installer
  line
  output "Preparing files..."
  prepare_files
  start_dusk
  line
  output_normal "Installation complete"
  line
  output "Wish lifechange case with DOUBLETOP"
}

main