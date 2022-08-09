#!/bin/bash
#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

docker stop streamr
docker container rm streamr
docker pull streamr/broker-node:testnet
docker run -it --restart=always --name=streamr -d -p 7170:7170 -p 7171:7171 -p 1883:1883 -v $(cd ~/.streamrDocker; pwd):/root/.streamr streamr/broker-node:testnet

echo DONE
