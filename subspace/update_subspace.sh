#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git ocl-icd-opencl-dev libopencl-clang-dev libgomp1 expect -y
}

function wget_pulsar {
    wget -O pulsar https://github.com/subspace/pulsar/releases/download/v0.6.4-alpha/pulsar-ubuntu-x86_64-skylake-v0.6.4-alpha 
    sudo chmod +x pulsar
    sudo mv pulsar /usr/local/bin/
}

function get_vars {
  export SUBSPACE_NODENAME=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-name" | awk -F\" '{print $4}')
  export WALLET_ADDRESS=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-reward-address" | awk -F\" '{print $4}')
}

function delete_old {
  docker-compose -f $HOME/subspace_docker/docker-compose.yml down -v &>/dev/null
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node &>/dev/null
}

function init_expect {
    sudo rm -rf $HOME/.config/pulsar
    expect <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/expect)
}

function systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/subspace.service
[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pulsar farm --verbose
Restart=on-failure
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable subspace
sudo systemctl restart subspace
}

function output_after_install {
    echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 5
    if [[ `systemctl status subspace | grep active` =~ "running" ]]; then
        echo -e "Your Subspace node \e[32minstalled and works\e[39m!"
        echo -e "You can check node status by the command \e[7msystemctl status subspace\e[0m"
        echo -e "Press \e[7mQ\e[0m for exit from status menu"
    else
        echo -e "Your Subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
    fi
}

function main {
  colors
  line
  logo
  line
  install_tools
  wget_pulsar
  get_vars
  delete_old
  init_expect
  systemd
  output_after_install
  line
}

main
