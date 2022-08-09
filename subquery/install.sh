#!/bin/bash

if [ ! $SUBQUERY_NODENAME ]; then
	read -p "Введите имя ноды: " SUBQUERY_NODENAME
fi
echo 'Имя ноды: ' $SUBQUERY_NODENAME
sleep 1
echo 'export SUBQUERY_NODENAME='$SUBQUERY_NODENAME >> $HOME/.profile

sudo apt update
sudo curl https://deb.nodesource.com/setup_14.x | sudo bash
sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt install nodejs=14.* yarn build-essential jq git -y

wget -O get-docker.sh https://get.docker.com 
sudo sh get-docker.sh
sudo apt install -y docker-compose
rm -f get-docker.sh

npm install -g @subql/cli
yarn global add @subql/cli




