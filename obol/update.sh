#!/bin/bash
docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
cd $HOME/charon-distributed-validator-node
git stash
git pull
cd $HOME/charon-distributed-validator-node/
git checkout -- $HOME/charon-distributed-validator-node/docker-compose.yml
cp $HOME/charon-distributed-validator-node/.env.sample $HOME/charon-distributed-validator-node/.env
echo -e "\nGETH_PORT_HTTP=18545" >> $HOME/charon-distributed-validator-node/.env
echo -e "\nLIGHTHOUSE_PORT_P2P=19000" >> $HOME/charon-distributed-validator-node/.env
echo -e "\nMONITORING_PORT_GRAFANA=4000" >> $HOME/charon-distributed-validator-node/.env
echo -e "\nCHARON_P2P_EXTERNAL_HOSTNAME=$(curl -s ifconfig.me)" >> $HOME/charon-distributed-validator-node/.env
sed -i -e 's/9100:9100/19100:9100/' $HOME/charon-distributed-validator-node/docker-compose.yml
sudo chmod -R 777 .charon
docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
echo "--------------------------------------------------"
echo "Обновление завершено"
