#!/bin/bash

sudo systemctl stop celestia-lightd

cd $HOME/celestia-node
git fetch
git checkout v0.8.1
make build
sudo make install

cd $HOME/.celestia-light-blockspacerace-0
sudo rm -rf blocks index data transients

celestia light init --p2p.network blockspacerace

sudo systemctl start celestia-lightd
