#!/bin/bash
if [ ! $IRONFISH_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " IRONFISH_NODENAME
fi
echo 'Ваше имя ноды: ' $IRONFISH_NODENAME
sleep 1
echo 'export NODENAME='$IRONFISH_NODENAME >> $HOME/.profile

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
echo "alias ironfish='docker exec ironfish ./bin/run'" >> ~/.profile
sleep 1
source $HOME/.profile

mkdir -p $HOME/ironfish/
sudo tee <<EOF >/dev/null $HOME/ironfish/docker-compose.yaml
version: "3.3"
services:
 ironfish:
  container_name: ironfish
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "sed -i 's%REQUEST_BLOCKS_PER_MESSAGE.*%REQUEST_BLOCKS_PER_MESSAGE = 5%' /usr/src/app/node_modules/ironfish/src/syncer.ts && apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' <http://127.0.0.1:9033> || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish:/root/.ironfish
 ironfish-miner:
  depends_on:
   - ironfish
  container_name: ironfish-miner
  image: ghcr.io/iron-fish/ironfish:latest
  command: miners:start --threads=1
  restart: always
  volumes:
   - $HOME/.ironfish:/root/.ironfish
EOF

docker-compose -f $HOME/ironfish/docker-compose.yaml up -d

docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run accounts:create $IRONFISH_NODENAME" ironfish
docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run accounts:use $IRONFISH_NODENAME" ironfish
docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run config:set nodeName $IRONFISH_NODENAME" ironfish
docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run config:set blockGraffiti $IRONFISH_NODENAME" ironfish
docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run config:set config:set minerBatchSize 60000" ironfish
docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run config:set enableTelemetry true" ironfish

custom_pool_addr=pool.ironfish.network
KEY=$(docker exec ironfish ./bin/run accounts:publickey | grep "public key:" | awk '{print $5}')

sudo tee <<EOF >/dev/null $HOME/ironfish/docker-compose.yaml
version: "3.3"
services:
 ironfish:
  container_name: ironfish
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "sed -i 's%REQUEST_BLOCKS_PER_MESSAGE.*%REQUEST_BLOCKS_PER_MESSAGE = 5%' /usr/src/app/node_modules/ironfish/src/syncer.ts && apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' <http://127.0.0.1:9033> || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish:/root/.ironfish
 ironfish-miner:
  depends_on:
   - ironfish
  container_name: ironfish-miner
  image: ghcr.io/iron-fish/ironfish:latest
  command: miners:start -v --pool $custom_pool_addr --address $KEY --threads=1
  restart: always
  volumes:
   - $HOME/.ironfish:/root/.ironfish
EOF

docker-compose -f $HOME/ironfish/docker-compose.yaml up -d

tmux kill-session -t ironfish
tmux new-session -d -s ironfish 'while true; do docker-compose -f $HOME/ironfish/docker-compose.yaml run --rm --entrypoint "./bin/run deposit -f 5000 --confirm" ironfish; sleep 60; done'
