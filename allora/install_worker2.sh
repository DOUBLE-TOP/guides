#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Установка Allora Worker"
echo "-----------------------------------------------------------------------------"

echo "Введите сид фразу от кошелька, который будет использоваться для воркера "
read WALLET_SEED_PHRASE

echo "Введите Coin Gecko API key"
read COIN_GECKO_API_KEY

cd $HOME
git clone https://github.com/allora-network/allora-huggingface-walkthrough
cd allora-huggingface-walkthrough
mkdir -p worker-data
chmod -R 777 worker-data

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/allora/config.json
sed -i "s|SeedPhrase|$WALLET_SEED_PHRASE|" $HOME/allora-huggingface-walkthrough/config.json
sed -i "s|<Your Coingecko API key>|$COIN_GECKO_API_KEY|" $HOME/allora-huggingface-walkthrough/app.py

chmod +x init.config
./init.config

sed -i "s|\"8000:8000\"|\"18000:8000\"|" $HOME/allora-huggingface-walkthrough/docker-compose.yaml
docker compose up -d --build

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
