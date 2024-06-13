#!/bin/bash

source $HOME/.profile

cd $HOME/0g-storage-node/
git fetch --all --tags
git checkout tags/$1
sudo systemctl stop 0g_storage
cargo build --release
sudo systemctl restart 0g_storage
