#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function cleanup {
  docker-compose -f $HOME/nwaku-compose/docker-compose.yml down
  mkdir -p $HOME/nwaku_backups
  if [ -d "$HOME/nwaku_backups/keystore0.36" ]; then
    echo "Бекап уже сделан"
  else
    echo "Делаем бекап ключей"
    mkdir -p $HOME/nwaku_backups/keystore0.36
    cp $HOME/nwaku-compose/keystore/keystore.json $HOME/nwaku_backups/keystore0.36/keystore.json
    rm -rf $HOME/nwaku-compose/keystore
  fi
  
  rm -rf $HOME/nwaku-compose/rln_tree
  cd $HOME/nwaku-compose
  git restore . &>/dev/null
}

function update {
  # Иницифализируем
  STORAGE_SIZE="50GB"
  POSTGRES_SHM="5g"
  ENV_FILE=$HOME/nwaku-compose/.env
  KEYSTORE_PATH="$HOME/nwaku-compose/keystore/keystore.json"
  # Выгружаем переменные с .env в среду выполнения
  sed -i '/^ETH_TESTNET_ACCOUNT=/d' $HOME/nwaku-compose/.env
  source $HOME/nwaku-compose/.env &>/dev/null

  # Удаляем старый .env
  rm -rf $HOME/nwaku-compose/.env
  cd $HOME/nwaku-compose
  git pull origin master
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


  #if [ -z "$RLN_RELAY_ETH_CLIENT_ADDRESS" ]; then
      echo -e "${GREEN}Введите ваш RPC Linea Sepolia https url. Пример url'a - https://linea-sepolia.infura.io/v3/ТУТ_ВАШ_КЛЮЧ${NORMAL}"
      read RLN_RELAY_ETH_CLIENT_ADDRESS
  #fi

  if [ -z "$ETH_TESTNET_KEY" ]; then
      echo -e "${GREEN}Введите ваш приватник от ETH кошелька (без 0х)${NORMAL}"
      read ETH_TESTNET_KEY
  fi

  if [ -z "$RLN_RELAY_CRED_PASSWORD" ]; then
      echo -e "${GREEN}Введите пароль который вводили в п.4 гайда${NORMAL}"
      read RLN_RELAY_CRED_PASSWORD
  fi

  echo -e "${GREEN}Вставьте весь текст из файла keystore.json и нажмите${NORMAL} ${RED}Ctrl+D${NORMAL}"
  USER_INPUT=$(cat)

  # Validate JSON
  echo "$USER_INPUT" | jq empty 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "JSON имеен некорректный формат. Отменяем установку."
    exit 1
  fi
  mkdir -p "$(dirname "$KEYSTORE_PATH")"
  echo "$USER_INPUT" > "$KEYSTORE_PATH"
  echo "keystore.json сохранен: $KEYSTORE_PATH"

  sed -i '/^ETH_TESTNET_ACCOUNT=/d' $HOME/nwaku-compose/.env
  sed -i "s|RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$RLN_RELAY_ETH_CLIENT_ADDRESS|" $HOME/nwaku-compose/.env
  sed -i "s|ETH_TESTNET_ACCOUNT=.*|ETH_TESTNET_ACCOUNT=$ETH_TESTNET_ACCOUNT|" $HOME/nwaku-compose/.env
  sed -i "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$ETH_TESTNET_KEY|" $HOME/nwaku-compose/.env
  sed -i "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=$RLN_RELAY_CRED_PASSWORD|" $HOME/nwaku-compose/.env
  sed -i "s|NWAKU_IMAGE=.*|NWAKU_IMAGE=wakuorg/nwaku:v0.36.0|" $HOME/nwaku-compose/.env
  

  # Меняем стандартный порт графаны
  sed -i '/^version: "3.7"$/d' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/0\.0\.0\.0:3000:3000/0.0.0.0:3004:3000/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/127\.0\.0\.1:4000:4000/0.0.0.0:4044:4000/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's|127.0.0.1:8003:8003|127.0.0.1:8333:8003|' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/:5432:5432/:5444:5432/g' $HOME/nwaku-compose/docker-compose.yml
  sed -i 's/80:80/8081:80/g' $HOME/nwaku-compose/docker-compose.yml

  #bash $HOME/nwaku-compose/register_rln.sh
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
echo -e "Останавливаем контейнер, чистим ненужные файлы и обновляемся"
cleanup
update
echo -e "Запускаем docker контейнеры для waku"
docker_compose_up
echo_info
