#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $ALCHEMY_KEY ]; then
	read -p "Введите ваш HTTP (ПРИМЕР: https://eth-goerli.alchemyapi.io/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN): " ALCHEMY_KEY
fi
echo 'Ваш ключ: ' $ALCHEMY_KEY
sleep 1
echo 'export ALCHEMY_KEY='$ALCHEMY_KEY >> $HOME/.bash_profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем зависимости"
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Клонируем репрозиторий"
echo "-----------------------------------------------------------------------------"
git clone https://github.com/eqlabs/pathfinder.git
cd $HOME/pathfinder
git fetch
git checkout `curl https://api.github.com/repos/eqlabs/pathfinder/releases/latest -s | jq .name -r`
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
