#!/bin/bash

sudo apt install lz4 -y
sudo systemctl stop 0g
cp $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup
0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book
curl https://server-5.itrocket.net/testnet/og/og_2024-08-12_628002_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.0gchain
mv $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json
sudo systemctl restart 0g
rm -f og_2024-08-12_628002_snap.tar.lz4