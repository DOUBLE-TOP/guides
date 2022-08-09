#!/bin/bash
#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

if [ ! $SUBSOCIAL_NODENAME ]; then
	read -p "Введите имя ноды: " SUBSOCIAL_NODENAME
fi
echo 'Ваше имя ноды: ' $SUBSOCIAL_NODENAME
sleep 1
echo 'export SUBSOCIAL_NODENAME='$SUBSOCIAL_NODENAME >> $HOME/.profile

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash

docker run -dit \
--name subsocial \
--restart always \
--log-opt max-size=100m \
--log-opt max-file=5 \
-p 30333:30333 \
-p 127.0.0.1:9933:9933 \
dappforce/subsocial-node:staging subsocial-node \
--validator --name "$SUBSOCIAL_NODENAME" \
--chain staging-testnet \
--rpc-cors all \
--rpc-methods=unsafe \
--rpc-external
