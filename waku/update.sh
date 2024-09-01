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

function cleanup {
  docker-compose -f $HOME/nwaku-compose/docker-compose.yml down
  mkdir -p $HOME/nwaku_backups
  if [ -d "$HOME/nwaku_backups/keystore0.30" ]; then
    echo "Бекап уже сделан"
  else
    echo "Делаем бекап ключей"
    mkdir -p $HOME/nwaku_backups/keystore0.30
    cp $HOME/nwaku-compose/keystore/keystore.json $HOME/nwaku_backups/keystore0.30/keystore.json
    rm -rf $HOME/nwaku-compose/keystore/
  fi
  
  rm -rf $HOME/nwaku-compose/rln_tree/ 
  cd $HOME/nwaku-compose
  git restore .
}

function update {
  # Выгружаем переменные с .env в среду выполнения
  source $HOME/nwaku-compose/.env

  # Удаляем старый .env
  rm -rf $HOME/nwaku-compose/.env
  cd $HOME/nwaku-compose
  git pull
  cp .env.example .env

  # Check which variable has a value
  if [ -n "$RLN_RELAY_ETH_CLIENT_ADDRESS" ]; then
    SEPOLIA_RPC="$RLN_RELAY_ETH_CLIENT_ADDRESS"
  elif [ -n "$ETH_CLIENT_ADDRESS" ]; then
    SEPOLIA_RPC="$ETH_CLIENT_ADDRESS"
  else
    echo "Проверьте .env файл"
    exit 1
  fi

  sed -i "s|RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$SEPOLIA_RPC|" $HOME/nwaku-compose/.env
  sed -i "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$ETH_TESTNET_KEY|" $HOME/nwaku-compose/.env
  sed -i "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=$RLN_RELAY_CRED_PASSWORD|" $HOME/nwaku-compose/.env
  sed -i "s|NWAKU_IMAGE=.*|NWAKU_IMAGE=harbor.status.im/wakuorg/nwaku:v0.32.0|" $HOME/nwaku-compose/.env


  # Меняем стандартный порт графаны, на случай если кто-то баловался с другими нодами 
  # и она у него висит и занимает порт. Сыграем на опережение=)
  sed -i 's/0\.0\.0\.0:3000:3000/0.0.0.0:3004:3000/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/127\.0\.0\.1:4000:4000/0.0.0.0:4044:4000/g' $HOME/nwaku-compose/docker-compose.yml

  bash register_rln.sh
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
line_1
logo
line_2
echo -e "Останавливаем контейнер, чистим ненужные файлы и обновляемся"
line_1
cleanup
update
line_1
echo -e "Запускаем docker контейнеры для waku"
line_1
docker_compose_up
line_2
echo_info
line_2
