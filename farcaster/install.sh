#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды Farcaster"
echo "-----------------------------------------------------------------------------"

cd $HOME && mkdir -p hubble && cd $HOME/hubble
rm -rf hubble.sh*
wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/farcaster/hubble.sh

bash hubble.sh "upgrade"

cd hubble
docker compose down
sleep 5
docker compose up -d

echo "-----------------------------------------------------------------------------"
echo "Farcaster Node успешно установлена"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов:"
echo "docker logs -f --tail=100 hubble-hubble-1"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
