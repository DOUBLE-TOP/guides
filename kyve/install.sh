#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null
# curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

# if [ ! -d $HOME/kyve/ ]; then
#   git clone https://github.com/KYVENetwork/kyve.git &>/dev/null
# fi

if [ ! -e $HOME/metamask.txt ]; then
	echo "Файл с приватником от ММ отсутствует"
  exit 1
fi

# if [ ! -e $HOME/arweave.json ]; then
# 	echo "Файл от расширения arweave.json отсутствует"
#   exit 1
# else
#   cp $HOME/arweave.json $HOME/kyve/integrations/node/
# fi

# tee <<EOF >/dev/null $HOME/kyve/integrations/node/config.json
# {
#   "pools": {
#     "0xbBBfbE9A731634eDdf84C67A106CEE1F981F3f7e": 10
#   }
# }
# EOF

# tee <<EOF >/dev/null $HOME/kyve/integrations/node/.env
# CONFIG=config.json
# WALLET=arweave.json
# SEND_STATISTICS=true
# PK=`cat $HOME/metamask.txt`
# EOF
#
# echo "Репозиторий склонирован, конфиг на месте, начинаем билд приложения"
# echo "-----------------------------------------------------------------------------"

# cd $HOME/kyve
# yarn setup &>/dev/null
#
# cd $HOME/kyve/integrations/node
# yarn node:build &>/dev/null
#
# docker rm -f kyve &>/dev/null
# docker run -d -it --restart=always --name=kyve kyve-node:latest &>/dev/null
#docker pull kyve/evm:latest &>/dev/null
docker pull kyve/evm:latest &>/dev/null
docker pull kyve/cosmos:latest &>/dev/null
docker pull kyve/solana-snapshots:latest &>/dev/null
docker pull kyve/celo:latest &>/dev/null

docker stop kyve kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null
docker container rm kyve kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null

docker run -d -it --restart=always \
--name kyve-avalanche kyve/evm:latest \
--pool 0x464200b29738367366FDb4c45f3b8fb582AE0Bf8 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-moonriver kyve/evm:latest \
--pool 0x610D55fA573Bce4D2d36e8ADAAee517B785a69dF \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-cosmos kyve/cosmos:latest \
--pool 0x7Bb18C81BBA6B8dE8C17B97d78B65327024F681f \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-solana kyve/solana-snapshots:latest \
--pool 0x3124375cA4de5FE5afD672EF2775c6bdcA1Cfdcc \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-celo kyve/celo:latest \
--pool 0x1588fd93715Aa08d67c32C6dF96fC730B15E1E1A \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

echo "Нода запущена, переходим к следующему пункту гайда"
echo "-----------------------------------------------------------------------------"
