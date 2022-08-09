#!/bin/bash

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function install_tools {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
  source ~/.cargo/env
  rustup default nightly
  sleep 1
}

function source_git {
  if [ ! -d $HOME/penumbra/ ]; then
    git clone https://github.com/penumbra-zone/penumbra
  fi
  cd $HOME/penumbra
  git fetch
  git checkout 024-dia && cargo update
}

function build_penumbra {
  if [ ! -d $HOME/penumbra/ ]; then
    cd $HOME/penumbra/
    cargo build --release --bin pcli
    sudo cp target/release/pcli /usr/bin/pcli
  else
    source_git
    cd $HOME/penumbra/
    cargo build --release --bin pcli
    sudo cp target/release/pcli /usr/bin/pcli
  fi
}

function generate_wallet {
  cd $HOME/penumbra/
  pcli wallet generate
}

colors

line
logo
line
echo -e "${RED}Начинаем установку ${NORMAL}"
line
echo -e "${GREEN}1/5 Устанавливаем софт ${NORMAL}"
line
install_tools
line
echo -e "${GREEN}2/5 Клонируем репозиторий ${NORMAL}"
line
source_git
line
echo -e "${GREEN}3/5 Начинаем билд ${NORMAL}"
line
build_penumbra
line
echo -e "${GREEN}4/5 Создаем кошелек ${NORMAL}"
line
generate_wallet
line
echo -e "${GREEN}5/5 Кошелек успешно создан, следуйте по гайду дальше ${NORMAL}"
line
echo -e "${RED}Скрипт завершил свою работу ${NORMAL}"
