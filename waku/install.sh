#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
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

function read_sepolia_rpc {
  if [ ! $RPC_URL ]; then
  echo -e "${GREEN}Введите ваш RPC Linea Sepolia https url. Пример url'a - https://linea-sepolia.infura.io/v3/ТУТ_ВАШ_КЛЮЧ${NORMAL}"
  read RPC_URL
  fi
}

function read_public_key {
  if [ ! $WAKU_PUBLIC_KEY ]; then
  echo -e "${GREEN}Введите ваш адрес ETH кошелека (начинается с 0х)${NORMAL}"
  read WAKU_PUBLIC_KEY
  fi
}

function read_private_key {
  if [ ! $WAKU_PRIVATE_KEY ]; then
  echo -e "${GREEN}Введите ваш приватник от ETH кошелека (без 0х)${NORMAL}"
  read WAKU_PRIVATE_KEY
  fi
}

function read_pass {
  if [ ! $WAKU_PASS ]; then
  echo -e "${GREEN}Введите пароль который вводили в п.4 гайда${NORMAL}"
  read WAKU_PASS
  fi
}

function git_clone {
  git clone https://github.com/waku-org/nwaku-compose
}

function setup_env {
  # Иницифализируем
  STORAGE_SIZE="50GB"
  POSTGRES_SHM="5g"
  ENV_FILE=$HOME/nwaku-compose/.env
  KEYSTORE_PATH="$HOME/nwaku-compose/keystore/keystore.json"
  
  cd nwaku-compose
  cp .env.example .env

  if grep -q "^STORAGE_SIZE=" "$ENV_FILE"; then
      sed -i "s/^STORAGE_SIZE=.*/STORAGE_SIZE=$STORAGE_SIZE/" "$ENV_FILE"
  else
      echo "STORAGE_SIZE=$STORAGE_SIZE" >> "$ENV_FILE"
  fi

  if grep -q "^POSTGRES_SHM=" "$ENV_FILE"; then
      sed -i "s/^POSTGRES_SHM=.*/POSTGRES_SHM=$POSTGRES_SHM/" "$ENV_FILE"
  else
      echo "POSTGRES_SHM=$POSTGRES_SHM" >> "$ENV_FILE"
  fi

  sed -i "s|RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$RPC_URL|" $HOME/nwaku-compose/.env
  sed -i "s|ETH_TESTNET_ACCOUNT=.*|ETH_TESTNET_ACCOUNT=$WAKU_PUBLIC_KEY|" $HOME/nwaku-compose/.env
  sed -i "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$WAKU_PRIVATE_KEY|" $HOME/nwaku-compose/.env
  sed -i "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=$WAKU_PASS|" $HOME/nwaku-compose/.env
  sed -i "s|NWAKU_IMAGE=.*|NWAKU_IMAGE=wakuorg/nwaku:v0.36.0|" $HOME/nwaku-compose/.env


  # Меняем стандартный порт графаны
  sed -i '/^version: "3.7"$/d' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/0\.0\.0\.0:3000:3000/0.0.0.0:3004:3000/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/127\.0\.0\.1:4000:4000/0.0.0.0:4044:4000/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's|127.0.0.1:8003:8003|127.0.0.1:8333:8003|' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's|- 80:80|- 1989:80|' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/:5432:5432/:5444:5432/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/80:80/8081:80/g' $HOME/nwaku-compose/docker-compose.yml

  bash $HOME/nwaku-compose/register_rln.sh
}


function docker_compose_up {
  docker compose -f $HOME/nwaku-compose/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml restart \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml logs -f --tail=100 \n ${NORMAL}"
  ip_address=$(hostname -I | awk '{print $1}') >/dev/null
  echo -e "${GREEN}Для проверки дашборда графаны, перейдите по ссылке: ${NORMAL}"
  echo -e "${RED}   http://$ip_address:3004/d/yns_4vFVk/nwaku-monitoring \n ${NORMAL}"
}

colors
logo
read_sepolia_rpc
read_public_key
read_private_key
read_pass
echo -e "Установка tools, ufw, docker"
install_tools
install_ufw
install_docker
echo -e "Клонируем репозиторий, готовим env"
git_clone
setup_env
echo -e "Запускаем docker контейнеры для waku"
docker_compose_up
echo_info
