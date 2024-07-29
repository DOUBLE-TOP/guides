#!/bin/bash
echo "-----------------------------------------------------------------------------"
echo "Выполняем обновление"
echo "-----------------------------------------------------------------------------"

source $HOME/.profile

cd $HOME/0g-chain
git fetch --all --tags
git checkout $1
sudo systemctl stop 0g
make install
sudo systemctl restart 0g
0gchaind version