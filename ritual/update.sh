#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

# Функция для запроса параметра у пользователя
request_param() {
    read -p "$1: " param
    echo $param
}

# Запрашиваем параметры у пользователя
echo "Пожалуйста, введите следующие параметры для настройки ноды:"
RPC_URL=$(request_param "Введите RPC URL")
PRIVATE_KEY=$(request_param "Введите ваш приватный ключ (начинающийся с 0x)")

if [[ "$PRIVATE_KEY" == 0x* ]]; then
    echo "Вы ввели приватный ключ верно!"
else
    echo "Приватный ключ введен не верно. Приватный ключ должен начинаться с 0x"
    exit 1
fi

REGISTRY_ADDRESS=0x3B1554f346DFe5c482Bb4BA31b880c1C18412170
IMAGE="ritualnetwork/infernet-node:1.4.0"

docker compose -f infernet-container-starter/deploy/docker-compose.yaml down

mv ~/infernet-container-starter ~/infernet-container-starter-backup
git clone https://github.com/ritual-net/infernet-container-starter

cp $HOME/infernet-container-starter/projects/hello-world/container/config.json $HOME/infernet-container-starter/deploy/config.json
# Конфигурация deploy/config.json
DEPLOY_JSON=$HOME/infernet-container-starter/deploy/config.json
sed -i 's|"rpc_url": "[^"]*"|"rpc_url": "'"$RPC_URL"'"|' "$DEPLOY_JSON"
sed -i 's|"private_key": "[^"]*"|"private_key": "'"$PRIVATE_KEY"'"|' "$DEPLOY_JSON"
sed -i 's|"registry_address": "[^"]*"|"registry_address": "'"$REGISTRY_ADDRESS"'"|' "$DEPLOY_JSON"
sed -i 's|"sleep": .*|"sleep": 3,|' "$DEPLOY_JSON"
sed -i 's|"batch_size": .*|"batch_size": 800,|' "$DEPLOY_JSON"
sed -i 's|"trail_head_blocks": .*|"trail_head_blocks": 3,|' "$DEPLOY_JSON"
sed -i 's|"sync_period": .*|"sync_period": 30|' "$DEPLOY_JSON"
sed -i 's|"starting_sub_id": .*|"starting_sub_id": 160000,|' "$DEPLOY_JSON"

# Конфигурация container/config.json
CONTAINER_JSON=$HOME/infernet-container-starter/projects/hello-world/container/config.json

sed -i 's|"rpc_url": "[^"]*"|"rpc_url": "'"$RPC_URL"'"|' "$CONTAINER_JSON"
sed -i 's|"private_key": "[^"]*"|"private_key": "'"$PRIVATE_KEY"'"|' "$CONTAINER_JSON"
sed -i 's|"registry_address": "[^"]*"|"registry_address": "'"$REGISTRY_ADDRESS"'"|' "$CONTAINER_JSON"
sed -i 's|"sleep": .*|"sleep": 3,|' "$CONTAINER_JSON"
sed -i 's|"batch_size": .*|"batch_size": 800,|' "$CONTAINER_JSON"
sed -i 's|"trail_head_blocks": .*|"trail_head_blocks": 3,|' "$CONTAINER_JSON"
sed -i 's|"sync_period": .*|"sync_period": 30|' "$CONTAINER_JSON"
sed -i 's|"starting_sub_id": .*|"starting_sub_id": 160000,|' "$CONTAINER_JSON"

# Конфигурация script/Deploy.s.sol
sed -i 's|address registry = .*|address registry = 0x3B1554f346DFe5c482Bb4BA31b880c1C18412170;|' "$HOME/infernet-container-starter/projects/hello-world/contracts/script/Deploy.s.sol"

# Конфигурация contracts/Makefile
MAKEFILE=$HOME/infernet-container-starter/projects/hello-world/contracts/Makefile
sed -i 's|sender := .*|sender := '"$PRIVATE_KEY"'|' "$MAKEFILE"
sed -i 's|RPC_URL := .*|RPC_URL := '"$RPC_URL"'|' "$MAKEFILE"

#Cтарт контейнеров для инициализации новой конфигурации
sed -i 's|ritualnetwork/infernet-node:.*|ritualnetwork/infernet-node:1.4.0|' $HOME/infernet-container-starter/deploy/docker-compose.yaml
sed -i 's|0.0.0.0:4000:4000|0.0.0.0:4321:4000|' $HOME/infernet-container-starter/deploy/docker-compose.yaml
sed -i 's|8545:3000|8845:3000|' $HOME/infernet-container-starter/deploy/docker-compose.yaml
sed -i 's|container_name: infernet-anvil|container_name: infernet-anvil\n    restart: on-failure|' $HOME/infernet-container-starter/deploy/docker-compose.yaml

docker compose -f $HOME/infernet-container-starter/deploy/docker-compose.yaml up -d

# Установка Foundry
cd $HOME
mkdir -p foundry
cd foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
echo 'export PATH="$PATH:/root/.foundry/bin"' >> .profile
source .profile

foundryup

# Установка зависимостей для контрактов
cd $HOME/infernet-container-starter/projects/hello-world/contracts/lib/
rm -r forge-std
rm -r infernet-sdk
forge install --no-commit foundry-rs/forge-std
forge install --no-commit ritual-net/infernet-sdk

# Deploy Consumer Contract
cd $HOME/infernet-container-starter
project=hello-world make deploy-contracts >> logs.txt
CONTRACT_ADDRESS=$(grep "Deployed SaysHello" logs.txt | awk '{print $NF}')
rm -rf logs.txt

if [ -z "$CONTRACT_ADDRESS" ]; then
  echo -e "${err}Произошла ошибка: не удалось прочитать contractAddress из $CONTRACT_DATA_FILE${end}"
  exit 1
fi

echo -e "${fmt}Адрес вашего контракта: $CONTRACT_ADDRESS${end}"
sed -i 's|0x13D69Cf7d6CE4218F646B759Dcf334D82c023d8e|'$CONTRACT_ADDRESS'|' "$HOME/infernet-container-starter/projects/hello-world/contracts/script/CallContract.s.sol"

# Call Consumer Contract
cd $HOME/infernet-container-starter
project=hello-world make call-contract

cd $HOME/infernet-container-starter/deploy

docker compose down
sleep 3
sudo rm -rf docker-compose.yaml
wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/ritual/docker-compose.yaml
docker compose up -d

docker rm -fv infernet-anvil  &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "docker compose -f $HOME/infernet-container-starter/deploy/docker-compose.yaml logs -f --tail=100"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"