#!/bin/bash

cd $HOME/initia
git fetch
git checkout $1
sudo systemctl stop initia
make install
sudo systemctl restart initia