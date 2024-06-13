#!/bin/bash

source $HOME/.profile

cd $HOME/0g-storage-node/
cp run/config.toml $HOME/config.toml.bak
git checkout -- run/config.toml
git fetch --all --tags
git checkout tags/$1
sudo systemctl stop 0g_storage
cargo build --release
mv $HOME/config.toml.bak run/config.toml
latest_block=$($HOME/go/bin/0gchaind status | jq -r .sync_info.latest_block_height)
sed -i 's/log_sync_start_block_number = [0-9]\+/log_sync_start_block_number = '"$latest_block"'/g' run/config.toml
sudo systemctl restart 0g_storage
