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


function update {
    cd $HOME/rusk
    docker-compose down
    cp -r dusk dusk-backup
    docker-compose run dusk bash -c "curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dusk/itn-installer.sh | bash"
    docker-compose up -d 
}

function main {
    colors
    logo
    line
    output "Обновление Dusk Network"
    line
    update
    line
    output_normal "Обновление завершено"
    line
}

main