#!/bin/bash

cd $HOME/cd 0g-chain
git fetch
git checkout $1
sudo systemctl stop 0g_storage
make install
sudo systemctl restart 0g_storage
