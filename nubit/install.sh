#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

sudo apt update && sudo apt upgrade -y && apt install curl -y

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды Nubit"
echo "-----------------------------------------------------------------------------"

mkdir nubit-node && cd nubit-node
wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/nubit/Dockerfile

docker build -t nubit_image . && docker run -d --name nubit nubit_image
sleep 60
docker cp nubit:/home/nubit-user/nubit-node/mnemonic.txt $HOME/nubit-node/mnemonic.txt
docker cp nubit:/home/nubit-user/.nubit-light-nubit-alphatestnet-1/keys $HOME/nubit-node/keys

docker logs nubit
