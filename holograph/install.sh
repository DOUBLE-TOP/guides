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

function main_tools {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
}

function node {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh)
}

function install_cli {
    npm install -g @holographxyz/cli
}

function holograph_config {
    holograph config
}

function holograph_faucet {
    holograph faucet
}

function holograph_operator {
    holograph operator:bond
}

colors
line
logo
line
echo "installing tools...."
line
main_tools
node
line
echo "installation holograph_cli"
line
install_cli
line
echo "install configuration"
holograph_config
line
echo "faucet"
holograph_faucet
line
echo "bonding into a pod"
holograph_operator
line

