#!/bin/bash

source $HOME/.profile

ver="1.20.3" 
cd $HOME 
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
rm "go$ver.linux-amd64.tar.gz"

sudo systemctl stop celestia-lightd

cd $HOME/celestia-node
git fetch
git checkout v0.9.2
make build
sudo make install

celestia light config-update --p2p.network blockspacerace

sudo systemctl start celestia-lightd
