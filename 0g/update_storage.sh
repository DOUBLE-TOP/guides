#!/bin/bash

source $HOME/.profile

cd $HOME/0g-storage-node/
git fetch
git checkout $1
sudo systemctl stop 0g_storage
cargo build --release
sudo systemctl restart 0g_storage
