#!/bin/bash

sudo systemctl stop kichain

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash
source $HOME/.profile
sleep 1

rm -rf $HOME/ki-tools
git clone https://github.com/KiFoundation/ki-tools.git
cd $HOME/ki-tools
git checkout testnet-ibc
make install

cd $HOME
mkdir $HOME/bk/kid/config/
cp $HOME/testnet/kid/config/node_key.json $HOME/bk/kid/config/node_key.json
cp $HOME/testnet/kid/config/priv_validator_key.json $HOME/bk/kid/config/priv_validator_key.json

rm -rf $HOME/testnet
mkdir -p $HOME/testnet/kid $HOME/testnet/kicli

kid init $KICHAIN_NODENAME --chain-id kichain-t-4 --home $HOME/testnet/kid/
cp $HOME/bk/kid/config/node_key.json $HOME/testnet/kid/config/
cp $HOME/bk/kid/config/priv_validator_key.json $HOME/testnet/kid/config/
wget -qO $HOME/testnet/kid/config/genesis.json https://raw.githubusercontent.com/KiFoundation/ki-networks/v0.1/Testnet/kichain-t-4/genesis.json

peers="46b25d81510f8dcc535ca0924961b266e4f59244@135.125.183.94:26656,ada3bbf64f963e764bfe003276354bd121e80ae0@95.111.248.200:26656,276f6fb420b3595b63c2a13d35868cb530a31578@65.21.159.19:26656,7e5710ee0b1576a78a21a89e1588b6c95ee69873@194.163.137.193:26656"
seeds="815d447b182bbfcf729ac016bc8bb44aa8e14520@94.23.3.107:27756"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/testnet/kid/config/config.toml
sed -i -e 's/^\(timeout_commit *=\).*/\1 "5s"/' $HOME/testnet/kid/config/config.toml

sudo systemctl restart kichain; sleep 30

kid status
