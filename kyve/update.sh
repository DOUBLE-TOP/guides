#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
docker pull kyve/evm:latest &>/dev/null


docker stop kyve kyve-moonbeam kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null
docker container rm kyve kyve-moonbeam kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null


docker run -d -it --restart=always \
--name kyve-moonbeam kyve/evm:latest \
--pool 0xFAA8A4d6AC08e8e470d5F4ED771D645d5CaF5957 \
--private-key `cat $HOME/metamask.txt` \
--stake 1000 \
--commission 10
-e https://rpc.testnet.moonbeam.network &>/dev/null



echo Обновление завершено
