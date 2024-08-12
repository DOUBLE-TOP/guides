#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Делаем бекап"
echo "-----------------------------------------------------------------------------"
mkdir 0g_backup
cp -r $HOME/.0gchain/keyring-file 0g_backup/keyring-file
cp -r $HOME/.0gchain/keyring-test/ 0g_backup/keyring-test
cp $HOME/.0gchain/config/priv_validator_key.json 0g_backup/priv_validator_key.json
cp $HOME/.0gchain/config/node_key.json 0g_backup/node_key.json
echo "-----------------------------------------------------------------------------"
echo "Удаляем данные старой сети"
echo "-----------------------------------------------------------------------------"
source .profile
source .bashrc
sleep 1
systemctl stop 0g
0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book
rm -rf $HOME/.0gchain/config/genesis.json
rm -rf $HOME/.0gchain/config/addrbook.json
echo "-----------------------------------------------------------------------------"
echo "Выполняем миграцию"
echo "-----------------------------------------------------------------------------"
cd 0g-chain/
git fetch 
git checkout v0.3.0
make install
0gchaind config chain-id zgtendermint_16600-2
0gchaind init $OG_NODENAME --chain-id zgtendermint_16600-2 &>/dev/null
wget https://github.com/0glabs/0g-chain/releases/download/v0.2.3/genesis.json -O $HOME/.0gchain/config/genesis.json
SEEDS="81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.0gchain/config/config.toml
sudo systemctl restart 0g
echo "Миграция выполнена"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
