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

function install_main_tools {
    echo -e "${YELLOW}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
}

function install_rust {
    echo -e "${YELLOW}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh) &>/dev/null
}

function install_docker {
    echo -e "${YELLOW}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null
}

function install {
    echo -e "${YELLOW}Подготовка app chain:${NORMAL}"
    git clone https://github.com/karnotxyz/madara-cli &>/dev/null
    cd madara-cli &>/dev/null
    cargo build --release &>/dev/null
}

function output {
    echo -e "${YELLOW}Переходим к конфигурации своего app chain приложения. Следуйте гайду и выполните:${NORMAL}"
    echo -e "./target/release/madara init"
}

function main {
    colors
    logo
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