#!/bin/bash

sed -i '/CHAIN_ID/d' $HOME/.profile
sed -i '/CHAIN_ID/d' $HOME/.bash_profile
unset CHAIN_ID
ufw disable

docker-compose -f $HOME/kroma-up/docker-compose.yml --profile validator down

KROMA_VALIDATOR__PRIVATE_KEY=$(cat $HOME/kroma-up/.env | grep KROMA_VALIDATOR__PRIVATE_KEY | awk -F'=' '{print $2}')
ip_addr=$(curl -s ifconfig.me)

cd $HOME/kroma-up

git checkout -- docker-compose.yml
git checkout -- scripts/entrypoint.sh

git pull origin main

cp .env.sample .env

sed -i "s|KROMA_VALIDATOR__PRIVATE_KEY=.*|KROMA_VALIDATOR__PRIVATE_KEY=$KROMA_VALIDATOR__PRIVATE_KEY|" $HOME/kroma-up/.env
sed -i "s|KROMA_NODE__L1_RPC_ENDPOINT=.*|KROMA_NODE__L1_RPC_ENDPOINT=http:\/\/$ip_addr:58545|" $HOME/kroma-up/.env
sed -i "s|KROMA_VALIDATOR__L1_RPC_ENDPOINT=.*|KROMA_VALIDATOR__L1_RPC_ENDPOINT=ws:\/\/$ip_addr:58546|" $HOME/kroma-up/.env


sed -i 's/--circuitparams.maxtxs = 0 \\/--circuitparams.maxtxs=0 \\/' $HOME/kroma-up/scripts/entrypoint.sh
sed -i '/- kroma-geth/!b;n;/user: root/!a\    user: root' $HOME/kroma-up/docker-compose.yml

docker-compose --profile validator up -d