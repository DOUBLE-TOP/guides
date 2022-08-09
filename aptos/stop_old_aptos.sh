#!/bin/bash

sudo systemctl stop aptos  &>/dev/null
sudo systemctl disable aptos &>/dev/null
cd $HOME/testnet/  &>/dev/null
docker-compose down &>/dev/null
docker volume rm aptos-fullnode aptos-validator &>/dev/null
cd $HOME/aptos_testnet/ &>/dev/null
