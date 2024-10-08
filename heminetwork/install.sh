#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка майнера Hemi Network"
echo "-----------------------------------------------------------------------------"

cd $HOME
wget https://github.com/hemilabs/heminetwork/releases/download/v0.4.4/heminetwork_v0.4.4_linux_amd64.tar.gz

tar -xvf heminetwork_v0.4.4_linux_amd64.tar.gz && rm heminetwork_v0.4.4_linux_amd64.tar.gz
mv heminetwork_v0.4.4_linux_amd64 heminetwork
rm -rf $HOME/heminetwork_v0.4.4_linux_amd64

echo "-----------------------------------------------------------------------------"
echo "Создание кошелька"
echo "-----------------------------------------------------------------------------"

cd $HOME/heminetwork
./keygen -secp256k1 -json -net="testnet" > $HOME/heminetwork/popm-address.json

ADDRESS=$(cat $HOME/heminetwork/popm-address.json | jq ".pubkey_hash")

echo "Ваш адрес сгенерированного кошелька"
echo "$ADDRESS"

echo "-----------------------------------------------------------------------------"
echo "Hemi Network успешно установлен"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
