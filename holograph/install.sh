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

function systemd_holograph {
    sudo tee /etc/systemd/system/holographd.service > /dev/null <<EOF
[Unit]
Description=Holograph
After=network.target

[Service]
Type=simple
User=root
ExecStart=holograph operator --mode=auto --unsafePassword=2topnodes --sync
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable holographd &>/dev/null
sudo systemctl restart holographd
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
echo "creating systemd file, adding to autostart, starting"
systemd_holograph
echo "installation complete, check logs by command:"
echo "sudo journalctl -u holographd -f -o cat"
