#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

# Запрос и запись значения переменной KROMA_KEY
if [ ! $KROMA_KEY ]; then
    read -p "Введите ваш Private key от кошелька MM: " KROMA_KEY
    echo 'Ваш ключ: ' $KROMA_KEY
fi
sleep 1

source $HOME/.profile
source $HOME/.bash_profile

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null

ufw disable
git clone https://github.com/kroma-network/kroma-up.git
cd $HOME/kroma-up
git pull origin main
./startup.sh
sleep 1
docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
sudo chmod +x /usr/bin/docker-compose
cd $HOME
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/sepolia.sh)
cp .env.sepolia .env
ip_addr=$(curl -s ifconfig.me)
sed -i "s|KROMA_NODE__L1_RPC_ENDPOINT=.*|KROMA_NODE__L1_RPC_ENDPOINT=http:\/\/$ip_addr:58545|" $HOME/kroma-up/.env
sed -i "s|KROMA_VALIDATOR__L1_RPC_ENDPOINT=.*|KROMA_VALIDATOR__L1_RPC_ENDPOINT=ws:\/\/$ip_addr:58546|" $HOME/kroma-up/.env
sed -i "s|KROMA_VALIDATOR__PRIVATE_KEY=.*|KROMA_VALIDATOR__PRIVATE_KEY=$KROMA_KEY|" $HOME/kroma-up/.env
sed -i 's/--circuitparams.maxtxs = 0 \\/--circuitparams.maxtxs=0 \\/' $HOME/kroma-up/scripts/entrypoint.sh
sed -i '/- kroma-geth/!b;n;/user: root/!a\    user: root' $HOME/kroma-up/docker-compose.yml

source $HOME/kroma-up/.env
cd $HOME/kroma-up/ && docker-compose --profile validator up -d

bash $HOME/kroma-up/sync_block.sh sepolia

echo "-----------------------------------------------------------------------------"
echo "Нода запущена. Переходите к следующему разделу для депозита в своего валидатора"
echo "-----------------------------------------------------------------------------"
