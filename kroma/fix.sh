#!/bin/bash

ufw disable
cd /root/kroma-up
docker compose --profile validator down -v
cd /home/geth/eth-docker/
docker compose down -v
cd $HOME
rm -rf /home/geth/eth-docker/
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/sepolia.sh)
sleep 360m
cd /root/kroma-up && docker compose --profile validator up -d
bash $HOME/kroma-up/sync_block.sh sepolia
sleep 5m
docker exec kroma-validator kroma-validator deposit --amount 600000000000000000