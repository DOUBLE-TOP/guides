#!/bin/bash

PRIV_KEY=$(dialog --inputbox "Enter your private key from your testnet Shardeum node(Metamask private key) :" 0 0 "" --stdout) && clear
WALLET_ADDR=$(dialog --inputbox "Enter your wallet address from your testnet Shardeum node(Metamask wallet) :" 0 0 "" --stdout) && clear

docker exec -it shardeum-dashboard operator-cli start
sleep 30
# docker exec -it -e PRIV_KEY=$PRIV_KEY shardeum-dashboard operator-cli stake 10
docker exec -it -e PRIV_KEY=$PRIV_KEY shardeum-dashboard sh -c "(sleep 10; echo '${PRIV_KEY}'; sleep 10) | operator-cli stake 10"
docker exec -it -e WALLET_ADDR=$WALLET_ADDR shardeum-dashboard operator-cli stake_info $WALLET_ADDR



