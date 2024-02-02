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

function get_nodename {
    if [ ! ${BOOL_NODENAME} ]; then
    echo -e "${YELLOW}Введите имя ноды(придумайте)${NORMAL}"
    line
    read BOOL_NODENAME
    source $HOME/.profile
    fi
}

function install_main_tools {
    echo -e "${YELLOW}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
}

function install_rust {
    echo -e "${YELLOW}Установка rust:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh)
}

function install_docker {
    echo -e "${YELLOW}Установка docker:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
}

function install {
    echo -e "${YELLOW}Запуск ноды boolnetwork в докере:${NORMAL}"
    mkdir -p $HOME/.boolnetwork/
    chown -R 1000:1000 .boolnetwork/
    docker run -d -v $HOME/.boolnetwork:/bool/.local/share/bnk-node --restart unless-stopped --name boolnetwork boolnetwork/bnk-node:release --validator --chain=tee --name $BOOL_NODENAME 
}

function output {
echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "docker logs -f --tail=100 boolnetwork"
    echo -e "${YELLOW}Для перезапуска выполняем команду:${NORMAL}"
    echo -e "docker restart boolnetwork"
}

function main {
    colors
    logo
    line
    get_nodename
    line
    install_main_tools
    install_rust
    install_docker
    line
    install
    line
    output
}

main