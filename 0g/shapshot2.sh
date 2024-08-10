#!/bin/bash

sudo apt install aria2 -y
sudo systemctl stop 0g
cp $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup
0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book
aria2c -x 16 -s 16 https://vps4.josephtran.xyz/0g/0gchain_snapshot.lz4 -d $HOME/.0gchain -o 0gchain_snapshot.lz4 && \
tar -Ilz4 -xf $HOME/.0gchain/0gchain_snapshot.lz4 -C $HOME/.0gchain
mv $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json
sudo systemctl restart 0g
rm $HOME/.0gchain/0gchain_snapshot.lz4