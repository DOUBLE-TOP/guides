#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git -y
}

function install_docker {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
}

function install_node {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh | bash
}

function install_cli {
  sh -c "$(curl -sSfL https://raw.githubusercontent.com/koii-network/k2-release/master/k2-install-init.sh)"
  export PATH="/root/.local/share/koii/install/active_release/bin:$PATH"
}

function generate_wallet {
  koii config set --url https://testnet.koii.live
  koii-keygen new --outfile ~/.config/koii/id.json --no-bip39-passphrase >> $HOME/koii_wallet.txt
}

function stop_w8_coin {
  koii address 
  echo "Используя гайд восстановите данный кошелек в расшерении Finnie (!ВАЖНО ПРОВЕРЬТЕ ЧТОБ КОШЕЛЕК СОВПАДАЛ!) выполните все задания на кране и введите |koii| для продолжения работы скрипта."
  while true; do
    read input
    if [ "$input" = "koii" ]; then
    echo "Продолжаем выполнение скрипта..."
        break
    else
        echo "Неверный ввод. Пожалуйста, введите 'koii' для продолжения..."
    fi
done
}

function clone_repo {
git clone https://github.com/koii-network/VPS-task
cd VPS-task
}

function env {
  sudo tee <<EOF >/dev/null $HOME/VPS-task/.env-local
######################################################
################## DO NOT EDIT BELOW #################
######################################################
# Location of main wallet Do not change this, it mounts the ~/.config/koii:/app/config if you want to change, update it in the docker-compose.yml
WALLET_LOCATION="/app/config/id.json"
# Node Mode
NODE_MODE="service"
# The nodes address
SERVICE_URL="http://localhost:8080"
# Intial balance for the distribution wallet which will be used to hold the distribution list. 
INITIAL_DISTRIBUTION_WALLET_BALANCE= 2
# Global timers which track the round time, submission window and audit window and call those functions
GLOBAL_TIMERS="false"
# HAVE_STATIC_IP is flag to indicate you can run tasks that host APIs
# HAVE_STATIC_IP=true
# To be used when developing your tasks locally and don't want them to be whitelisted by koii team yet
RUN_NON_WHITELISTED_TASKS=true
# The address of the main trusted node
# TRUSTED_SERVICE_URL="https://k2-tasknet.koii.live"
######################################################
################ DO NOT EDIT ABOVE ###################
######################################################

# For the purpose of automating the staking wallet creation, the value must be greater 
# than the sum of all TASK_STAKES, the wallet will only be created and staking on task 
# will be done if it doesn't already exist
INITIAL_STAKING_WALLET_BALANCE=3

# environment
ENVIRONMENT="production"

# Location of K2 node
K2_NODE_URL="https://testnet.koii.live"

# Tasks to run and their stakes. This is the varaible you can add your Task ID to after
# registering with the crete-task-cli. This variable supports a comma separated list:
# TASKS="id1,id2,id3"
# TASK_STAKES="1,1,1"
TASKS="6GbpHRK3duDbo3dCEFXuJ2KD5Hg6Yo4A9LyHozeE7rjN"
TASK_STAKES=2

# User can enter as many environment variables as they like below. These can be task
# specific variables that are needed for the task to perform it's job. Some examples:
WEB3_STORAGE_KEY=""
SCRAPING_URL=""
EOF
}

function docker_compose_up {
  docker-compose -f $HOME/VPS-task/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды koii_task: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/VPS-task/docker-compose.yaml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды koii_task: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/VPS-task/docker-compose.yaml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды koii_task: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/VPS-task/docker-compose.yaml restart \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/VPS-task/docker-compose.yaml logs -f --tail=100 \n ${NORMAL}"
}

colors
line_1
logo
line_2
echo -e "Установка tools, ufw, docker, node"
line_1
install_tools
install_ufw
install_docker
install_node
line_1
echo -e "Устанавливаем cli и готовим кошелек"
line_1
install_cli
generate_wallet
stop_w8_coin
line_1
echo -e "Подготовка фалов для запуска koii"
line_1
clone_repo
env
line_1
echo -e "Запускаем docker контейнеры для koii"
line_1
docker_compose_up
line_2
echo_info
line_2
