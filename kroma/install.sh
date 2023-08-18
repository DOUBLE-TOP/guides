#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем переменные"
echo "-----------------------------------------------------------------------------"
# Запрос и запись значения переменной KROMA_KEY
if [ ! $KROMA_KEY ]; then
    read -p "Введите ваш Private key от кошелька MM: " KROMA_KEY
    echo 'Ваш ключ: ' $KROMA_KEY
fi
sleep 1
echo 'export KROMA_KEY='$KROMA_KEY >> $HOME/.bash_profile
source $HOME/.profile
source $HOME/.bash_profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем зависимости"
echo "-----------------------------------------------------------------------------"
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Клонируем репозиторий"
echo "-----------------------------------------------------------------------------"
ufw disable
git clone https://github.com/kroma-network/kroma-up.git
cd $HOME/kroma-up
git pull origin main
./startup.sh
echo "-----------------------------------------------------------------------------"
echo "Создаем env файл"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null $HOME/kroma-up/.env
############################### DEFAULT #####################################
# Network to run the node on ("sepolia")
NETWORK_NAME=sepolia

IMAGE_TAG__KROMA_GETH=v0.1.0
IMAGE_TAG__KROMA_NODE=v0.2.2
IMAGE_TAG__KROMA_VALIDATOR=v0.2.2

# Specifies the L1 RPC ENDPOINT. 
# By default, you can check and use an rpc endpoint with the following path: https://sepolia.dev/, but you can also use Alchemy or Infura, etc.
L1_RPC_ENDPOINT=https://rpc.sepolia.org

KROMA_GETH__BOOT_NODES=enode://94d5e63c23a091a891769048203faa77f08ec4d3ea023a3fe92810d0406329429de841d0500bc9eb0ca5ecb8e030ea38661669bf3c4fc132920a60da03ab8b57@43.200.87.213:30304?discport=30303,enode://d4c12295f2fa7b2e66688d79266086c6ea97ba1cbc63e770a96b05817412ec66ef49058ae86de2afc5aafbc2f54acb36503ac32580ee98e289e86985e97bcbcb@15.165.246.25:30304?discport=30303
KROMA_NODE__BOOT_NODES=/ip4/43.200.87.213/tcp/9003/p2p/16Uiu2HAmHh1piCDZ5bqD2gzY5nrnN8Aakt6E4xeWLCgNoZKGNKT5,/ip4/15.165.246.25/tcp/9003/p2p/16Uiu2HAmN7x7mKBZPGiMvrMeBN3Dn1ZbLzEe8i1vSug2gfCtHLnt

####################################
# The following settings are used to act as a validator.
# We recommend the values we provide as examples by default

KROMA_VALIDATOR__OUTPUT_SUBMITTER_DISABLED=false

# To act as a validator, you must use either your account's PRIVATE_KEY or your MNEMONIC and HD_PATH.
KROMA_VALIDATOR__MNEMONIC=
KROMA_VALIDATOR__HD_PATH=
KROMA_VALIDATOR__PRIVATE_KEY=$KROMA_KEY

# TBD
KROMA_VALIDATOR__CHALLENGER_DISABLED=true
KROMA_VALIDATOR__GUARDIAN_ENABLED=false
KROMA_VALIDATOR__PROVER_GRPC=
EOF

ip_addr=$(curl -s ifconfig.me)
sed -i "s/L1_RPC_ENDPOINT=.*/L1_RPC_ENDPOINT=http:\/\/$ip_addr:58545/" $HOME/kroma-up/.env

source $HOME/kroma-up/.env
sleep 1
echo "-----------------------------------------------------------------------------"
echo "Создаем docker-compose.yml файл"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null $HOME/kroma-up/docker-compose.yml
version: '3.9'
x-logging: &logging
  logging:
    driver: json-file
    options:
      max-size: 10m
      max-file: "3"

services:
  kroma-geth:
    container_name: kroma-geth
    image: kromanetwork/geth:${IMAGE_TAG__KROMA_GETH:-dev-fa80ead}
    restart: unless-stopped
    env_file:
      - envs/${NETWORK_NAME}/geth.env
    entrypoint: 
      - /bin/sh
      - /.kroma/entrypoint.sh
    ports:
      - 6060:6060
      - 8545:8545
      - 8546:8546
      - 8551:8551
      - 30304:30304/tcp
      - 30303:30303/udp
    volumes:
      - db:/.kroma/db
      - ./keys/jwt-secret.txt:/.kroma/keys/jwt-secret.txt
      - ./config/${NETWORK_NAME}/genesis.json:/.kroma/config/genesis.json
      - ./scripts/entrypoint.sh:/.kroma/entrypoint.sh
    profiles:
      - vanilla
      - validator
    <<: *logging

  kroma-node:
    depends_on:
      - kroma-geth
    user: root
    container_name: kroma-node
    image: kromanetwork/node:${IMAGE_TAG__KROMA_NODE:-v0.2.2}
    restart: unless-stopped
    env_file:
      - envs/${NETWORK_NAME}/node.env
    ports:
      - 9545:8545
      - 7300:7300
      - 9003:9003/tcp
      - 9003:9003/udp
    volumes:
      - ./keys/p2p-node-key.txt:/.kroma/keys/p2p-node-key.txt
      - ./keys/jwt-secret.txt:/.kroma/keys/jwt-secret.txt
      - ./config/${NETWORK_NAME}/rollup.json:/.kroma/config/rollup.json
      - ./logs:/.kroma/logs
    profiles:
      - vanilla
      - validator
    <<: *logging

  kroma-validator:
    depends_on:
      - kroma-node
    container_name: kroma-validator
    image: kromanetwork/validator:${IMAGE_TAG__KROMA_VALIDATOR:-v0.2.2}
    restart: unless-stopped
    env_file:
      - envs/${NETWORK_NAME}/validator.env
    profiles:
      - validator
    <<: *logging

volumes:
  db:
EOF
echo "-----------------------------------------------------------------------------"
echo "Запускаем ноду Kroma"
echo "-----------------------------------------------------------------------------"
docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
sudo chmod +x /usr/bin/docker-compose

cd $HOME
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/sepolia.sh)

cd $HOME/kroma-up/ && docker-compose --profile validator up -d

bash $HOME/kroma-up/sync_block.sh

echo "-----------------------------------------------------------------------------"
echo "Нода запущена. Переходите к следующему разделу для депозита в своего валидатора"
echo "-----------------------------------------------------------------------------"
