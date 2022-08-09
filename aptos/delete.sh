#!/bin/bash

cd $HOME
docker-compose -f $HOME/aptos_testnet/docker-compose.yaml down
sleep 5
rm -rf $HOME/aptos_testnet/
docker volume rm aptos-validator -f
