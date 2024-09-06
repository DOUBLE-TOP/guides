#!/bin/bash

# Переходим в директорию с конфигурационным файлом
cd $HOME/allora-huggingface-walkthrough || { echo "Не удалось зайти в директорию allora-huggingface-walkthrough"; exit 1; }

# Запрашиваем новый RPC у пользователя
read -p "Введите новый RPC URL: " new_rpc

# Заменяем RPC в конфигурационном файле
sed -i "s|\"nodeRpc\": \".*\"|\"nodeRpc\": \"$new_rpc\"|" config.json

# Выполняем команды для перезапуска Docker
docker compose down -v
chmod +x init.config
./init.config
docker compose up -d

echo "RPC обновлён и Docker-контейнеры перезапущены."