#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем зависимости"
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Обновляем репрозиторий"
echo "-----------------------------------------------------------------------------"
cd $HOME/pathfinder
git fetch
git checkout `curl https://api.github.com/repos/eqlabs/pathfinder/releases/latest -s | jq .name -r`
echo "-----------------------------------------------------------------------------"
echo "Останавливаем старую версию StarkNet, запущенную через systemd"
echo "-----------------------------------------------------------------------------"
sudo systemctl stop starknet &>/dev/null
sudo systemctl disable starknet &>/dev/null
rm -rf $HOME/pathfinder/py/.venv &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Создаем env файл с переменной Alchemy или infura"
echo "-----------------------------------------------------------------------------"
source $HOME/.bash_profile
echo "PATHFINDER_ETHEREUM_API_URL=$ALCHEMY_KEY" > pathfinder-var.env
echo "-----------------------------------------------------------------------------"
echo "Скачиваем последнюю версию docker image"
docker-compose pull
echo "Скачали, переходим к запуску"
echo "-----------------------------------------------------------------------------"
mkdir -p $HOME/pathfinder/pathfinder
chown -R 1000.1000 .
sleep 1
docker-compose up -d
echo "Нода обновлена и запущена"
echo "-----------------------------------------------------------------------------"
