#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
sudo apt update &>/dev/null
sudo apt install jq -y &>/dev/null
blockGraffiti=`docker exec ironfish ./bin/run config:show | jq -r .blockGraffiti`
nodeName=`docker exec ironfish ./bin/run config:show | jq -r .nodeName`

cd $HOME
var=`docker-compose logs --tail=1000 ironfish | grep "Added block to fork seq"`

if [ -z "$var" ]
then
  echo "выполняем обновление"
  echo "-----------------------------------------------------------------------------"
  docker-compose run --rm --entrypoint "./bin/run config:set minerBatchSize 60000" ironfish
  docker-compose run --rm --entrypoint "./bin/run config:set enableTelemetry true" ironfish
  docker-compose down
  docker-compose pull
  docker-compose up -d
else
  echo "выполняем сброс и обновление"
  echo "-----------------------------------------------------------------------------"
  wallet_name=`docker exec ironfish ./bin/run accounts:which` &>/dev/null
  docker exec ironfish rm -f wallet &>/dev/null
  docker exec ironfish ./bin/run accounts:export $wallet_name wallet &>/dev/null
  docker cp ironfish:/usr/src/app/wallet .
  docker-compose down
  docker-compose pull
  rm -f $HOME/.ironfish/accounts.backup.json
  docker-compose run --rm --entrypoint "./bin/run reset --confirm" ironfish
  docker-compose run -v $HOME/wallet:/usr/src/app/wallet --rm --entrypoint "./bin/run accounts:import wallet" ironfish
  docker-compose run --rm --entrypoint "./bin/run accounts:use $wallet_name" ironfish &>/dev/null
  docker-compose run --rm --entrypoint "./bin/run config:set nodeName $nodeName" ironfish
  docker-compose run --rm --entrypoint "./bin/run config:set blockGraffiti $blockGraffiti" ironfish
  docker-compose run --rm --entrypoint "./bin/run config:set minerBatchSize 60000" ironfish
  docker-compose run --rm --entrypoint "./bin/run config:set enableTelemetry true" ironfish
  docker-compose up -d
fi
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
