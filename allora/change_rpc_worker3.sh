#!/bin/bash

# Переходим в директорию с конфигурационным файлом
cd $HOME/allora-worker-x-reputer/allora-node || { echo "Не удалось зайти в директорию allora-worker-x-reputer/allora-node"; exit 1; }

# Запрашиваем новый RPC у пользователя
read -p "Введите новый RPC URL: " new_rpc

# Заменяем RPC в конфигурационном файле
sed -i "s|ALLORA_VALIDATOR_API_URL=.*|ALLORA_VALIDATOR_API_URL=$new_rpc|" $HOME/allora-worker-x-reputer/allora-node/docker-compose.yaml
sed -i "s|ALLORA_VALIDATOR_API_URL=.*|ALLORA_VALIDATOR_API_URL=$new_rpc|" $HOME/allora-worker-x-reputer/allora-node/docker-compose-reputer.yaml

# Выполняем команды для перезапуска Docker
docker compose down -v
docker compose up -d

echo "RPC обновлён и Docker-контейнеры перезапущены."