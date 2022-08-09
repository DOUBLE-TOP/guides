#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
cd $HOME
wallet_name=`docker exec ironfish ./bin/run accounts:which` &>/dev/null
docker exec ironfish rm -f wallet
docker exec ironfish ./bin/run accounts:export $wallet_name wallet &>/dev/null
docker cp ironfish:/usr/src/app/wallet .
docker-compose down &>/dev/null
docker-compose pull &>/dev/null
docker-compose up -d &>/dev/null
rm -f $HOME/.ironfish/accounts.backup.json
docker exec ironfish-miner ./bin/run reset --confirm
docker-compose restart
docker cp wallet ironfish:/usr/src/app/wallet
docker exec ironfish ./bin/run accounts:import wallet
docker exec ironfish ./bin/run accounts:use $wallet_name &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
