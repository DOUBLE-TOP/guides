#!/bin/bash

cd $HOME/initia
git checkout $1
sudo systemctl stop initia
make install
sudo systemctl restart initia