#!/bin/bash

sudo apt install lz4 -y
sudo systemctl stop 0g
cp $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup
0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book
curl https://snapshot.nodecattel.xyz/0gchain/zgtendermint_16600-2_latest.tar.lz4 | sudo lz4 -dc - | sudo tar -xf - -C $HOME/.0gchain
mv $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json
sudo systemctl restart 0g
rm -f zgtendermint_16600-2_latest.tar.lz4 