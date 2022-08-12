#!/bin/bash

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

ironfish accounts:create $IRONFISH_NODENAME
ironfish accounts:use $IRONFISH_NODENAME
ironfish config:set nodeName $IRONFISH_NODENAME
ironfish config:set blockGraffiti $IRONFISH_NODENAME
ironfish config:set minerBatchSize 60000
ironfish config:set enableTelemetry true

custom_pool_addr=pool.ironfish.network
KEY=$(ironfish accounts:publickey | grep "public key:" | awk '{print $5}')

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

tmux new-session -d -s ironfish 'while true; do docker-compose -f $HOME/docker-compose.yaml run --rm --entrypoint "./bin/run deposit -f 5000 --confirm" ironfish; sleep 60; done'
