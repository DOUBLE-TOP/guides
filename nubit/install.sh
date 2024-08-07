#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды Nubit"
echo "-----------------------------------------------------------------------------"

mkdir nubit-node && cd nubit-node
wget -O Dockerfile https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/nubit/Dockerfile.install

docker build --no-cache -t nubit_image . && docker run -d --name nubit --restart always nubit_image

echo "-----------------------------------------------------------------------------"
echo "Light Nubit Node успешно установлена"
echo "-----------------------------------------------------------------------------"
echo "Mnemonic"
echo "cat $HOME/nubit-node/mnemonic.txt"
echo "-----------------------------------------------------------------------------"
echo "Backup Keys from folder"
echo "$HOME/nubit-node/keys"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов:"
echo "docker logs -f --tail=100 nubit"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
