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

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update -y
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null

source .profile
source .bashrc
sleep 3

echo "-----------------------------------------------------------------------------"
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

# Клонирование репозитория
cd $HOME
git clone https://github.com/ritual-net/infernet-container-starter && cd infernet-container-starter

cp ./projects/hello-world/container/config.json deploy/config.json
docker compose -f deploy/docker-compose.yaml up -d

# Создание и настройка systemd службы для деплоя контейнера
# sudo tee /etc/systemd/system/deploy-container.service <<EOF
# [Unit]
# Description=Deploy Container Service
# After=network.target

# [Service]
# Type=simple
# ExecStart=/bin/bash -c 'cd /root/infernet-container-starter && project=hello-world make deploy-container'
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target
# EOF

# sudo systemctl daemon-reload
# sudo systemctl enable deploy-container
# sudo systemctl start deploy-container

# Добавляем переменные
echo export DEPLOY_JSON="$HOME/infernet-container-starter/deploy/config.json" >> ~/.bash_profile
echo export CONTAINER_JSON="$HOME/infernet-container-starter/projects/hello-world/container/config.json" >> ~/.bash_profile
echo export MAKEFILE="$HOME/infernet-container-starter/projects/hello-world/contracts/Makefile" >> ~/.bash_profile
echo export REG_ADDR="0x3B1554f346DFe5c482Bb4BA31b880c1C18412170" >> ~/.bash_profile
echo export IMAGE="ritualnetwork/hello-world-infernet:1.0.0" >> ~/.bash_profile
source ~/.bash_profile

# Конфигурация deploy/config.json
sed -i 's|"rpc_url": "[^"]*"|"rpc_url": "'"$RPC_URL"'"|' "$DEPLOY_JSON"
sed -i 's|"private_key": "[^"]*"|"private_key": "'"$PRIVATE_KEY"'"|' "$DEPLOY_JSON"
sed -i 's|"registry_address": "[^"]*"|"registry_address": "'"$REG_ADDR"'"|' "$DEPLOY_JSON"
sed -i 's|"image": "[^"]*"|"image": "'"$IMAGE"'"|' "$DEPLOY_JSON"
jq '. += { "snapshot_sync": { "sleep": 5, "batch_size": 50 } }' "$DEPLOY_JSON" > temp.json && mv temp.json "$DEPLOY_JSON"

# Конфигурация container/config.json
sed -i 's|"rpc_url": "[^"]*"|"rpc_url": "'"$RPC_URL"'"|' "$CONTAINER_JSON"
sed -i 's|"private_key": "[^"]*"|"private_key": "'"$PRIVATE_KEY"'"|' "$CONTAINER_JSON"
sed -i 's|"registry_address": "[^"]*"|"registry_address": "'"$REG_ADDR"'"|' "$CONTAINER_JSON"
sed -i 's|"image": "[^"]*"|"image": "'"$IMAGE"'"|' "$CONTAINER_JSON"
jq '. += { "snapshot_sync": { "sleep": 5, "batch_size": 50 } }' "$CONTAINER_JSON" > temp.json && mv temp.json "$CONTAINER_JSON"

# Конфигурация script/Deploy.s.sol
sed -i 's|address registry = .*|address registry = 0x3B1554f346DFe5c482Bb4BA31b880c1C18412170;|' "$HOME/infernet-container-starter/projects/hello-world/contracts/script/Deploy.s.sol"


# Конфигурация contracts/Makefile
sed -i 's|sender := .*|sender := '"$PRIVATE_KEY"'|' "$MAKEFILE"
sed -i 's|RPC_URL := .*|RPC_URL := '"$RPC_URL"'|' "$MAKEFILE"

#Рестарт контейнеров для инициализации новой конфигурации
# docker-compose -f $HOME/infernet-container-starter/deploy/docker-compose.yaml restart && sudo systemctl restart deploy-container
docker restart deploy-fluentbit-1 infernet-anvil deploy-redis-1 infernet-node hello-world

make deploy-contracts project=hello-world


# Установка Foundry
cd $HOME
mkdir -p foundry
cd foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# Установка зависимостей для контрактов
cd $HOME/infernet-container-starter/projects/hello-world/contracts/lib/
rm -r forge-std
rm -r infernet-sdk
forge install --no-commit foundry-rs/forge-std
forge install --no-commit ritual-net/infernet-sdk

# Deploy Consumer Contract
cd $HOME/infernet-container-starter
project=hello-world make deploy-contracts








# Получение адреса контракта из файла run-latest.json
CONTRACT_DATA_FILE="/root/infernet-container-starter/projects/hello-world/contracts/broadcast/Deploy.s.sol/8453/run-latest.json"
CONFIG_FILE="/root/infernet-container-starter/deploy/config.json"
CONTRACT_ADDRESS=$(jq -r '.receipts[0].contractAddress' "$CONTRACT_DATA_FILE")

if [ -z "$CONTRACT_ADDRESS" ]; then
  echo -e "${err}Произошла ошибка: не удалось прочитать contractAddress из $CONTRACT_DATA_FILE${end}" | tee -a "$log_file"
  exit 1
fi

echo -e "${fmt}Адрес вашего контракта: $CONTRACT_ADDRESS${end}" | tee -a "$log_file"

# Добавление параметров snapshot_sync в config.json
jq '. += { "snapshot_sync": { "sleep": 5, "batch_size": 25 } }' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

# Добавление адреса контракта в allowed_addresses в config.json
jq --arg contract_address "$CONTRACT_ADDRESS" '.containers[] |= if .id == "hello-world" then .allowed_addresses += [$contract_address] else . end' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

cat "$CONFIG_FILE" | tee -a "$log_file"

# Перезапуск Docker контейнера deploy-node-1
docker restart deploy-node-1
check_error "Не удалось перезапустить deploy-node-1"


# Просмотр статуса ноды
echo -e "${fmt}Проверка статуса ноды...${end}"
curl localhost:4000/health
