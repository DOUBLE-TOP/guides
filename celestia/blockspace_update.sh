#!/bin/bash

source $HOME/.profile

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)

sudo systemctl stop celestia-lightd

cd $HOME/celestia-node
git fetch
git checkout v0.9.1
make build
sudo make install

celestia light config-update --p2p.network blockspacerace

sudo systemctl start celestia-lightd
