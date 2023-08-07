#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем зависимости"
echo "-----------------------------------------------------------------------------"
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null

echo "Создаем docker-compose файл"
echo "-----------------------------------------------------------------------------"
cd
mkdir muon && cd muon
curl -o docker-compose.yml https://raw.githubusercontent.com/muon-protocol/muon-node-js/testnet/docker-compose-pull.yml
echo "-----------------------------------------------------------------------------"
echo "Запускаем ноду Muon"
echo "-----------------------------------------------------------------------------"
docker compose -f $HOME/moun/docker-compose.yml up -d
echo "-----------------------------------------------------------------------------"
echo "Нода обновлена и запущена. Следуйте дальше гайду"
echo "-----------------------------------------------------------------------------"
