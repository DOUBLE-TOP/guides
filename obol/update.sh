#!/bin/bash

cd $HOME/charon-distributed-validator-node
git stash
git pull
git checkout -- docker-compose.yml
cp $HOME/charon-distributed-validator-node/.env.sample $HOME/charon-distributed-validator-node/.env
IP_ADDR=$(curl -s ifconfig.me);sed -i -e 's/CHARON_P2P_EXTERNAL_HOSTNAME:-.*/CHARON_P2P_EXTERNAL_HOSTNAME:-'"$IP_ADDR"'}/;s/--http.port=8545/--http.port=18545/;s/8545:8545/18545:18545/;s/3000:3000/4000:3000/;s/9100:9100/19100:9100/;s/9000:9000/19000:9000/' $HOME/charon-distributed-validator-node/docker-compose.yml
docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
echo "--------------------------------------------------"
echo "Обновление завершено"
