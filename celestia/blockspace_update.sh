#!/bin/bash

source $HOME/.profile

sudo systemctl stop celestia-lightd

cd $HOME/celestia-node
git fetch
git checkout v0.9.1
make build
sudo make install

celestia light config-update --p2p.network blockspacerace

sudo systemctl start celestia-lightd
