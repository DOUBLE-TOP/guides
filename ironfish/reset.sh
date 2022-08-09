#!/bin/bash

blockGraffiti=`docker exec ironfish ./bin/run config:show | jq -r .blockGraffiti`
nodeName=`docker exec ironfish ./bin/run config:show | jq -r .nodeName`
wallet_name=`docker exec ironfish ./bin/run accounts:which`

docker-compose down
rm -f $HOME/.ironfish/accounts.backup.json
docker-compose run --rm --entrypoint "./bin/run reset --confirm" ironfish
docker-compose run -v $HOME/wallet:/usr/src/app/wallet --rm --entrypoint "./bin/run accounts:import wallet" ironfish
docker-compose run --rm --entrypoint "./bin/run accounts:use $wallet_name" ironfish &>/dev/null
docker-compose run --rm --entrypoint "./bin/run config:set nodeName $nodeName" ironfish
docker-compose run --rm --entrypoint "./bin/run config:set blockGraffiti $blockGraffiti" ironfish
docker-compose up -d
