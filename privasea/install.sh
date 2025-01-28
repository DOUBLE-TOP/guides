#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем ноду"
echo "-----------------------------------------------------------------------------"

mkdir -p $HOME/privasea/config

docker pull privasea/acceleration-node-beta:latest

docker run -it -v "$HOME/privasea/config:/app/config"  privasea/acceleration-node-beta:latest ./node-calc new_keystore

docker rm -f $(docker ps -a | grep privasea | awk '{print $1}') &>/dev/null

mv $HOME/privasea/config/UTC-* $HOME/privasea/config/wallet_keystore


echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "docker logs -f --tail=100 privasea-node"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"