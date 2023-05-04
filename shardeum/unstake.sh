#!/bin/bash
PRIV_KEY=$(dialog --inputbox "Enter your private key from your testnet Shardeum node(Metamask private key) :" 0 0 "enter private key" --stdout) && clear
WALLET_ADDR=$(dialog --inputbox "Enter your wallet address from your testnet Shardeum node(Metamask wallet) :" 0 0 "0x000000......" --stdout) && clear

docker exec -it -e WALLET_ADDR=$WALLET_ADDR shardeum-dashboard operator-cli stake_info $WALLET_ADDR
docker exec -it -e PRIV_KEY=$PRIV_KEY shardeum-dashboard operator-cli unstake -f