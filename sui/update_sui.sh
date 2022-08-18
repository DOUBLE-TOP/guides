#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Выполняем обновление"
echo "-----------------------------------------------------------------------------"
sudo systemctl stop sui
rm -rf $HOME/.sui/db
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
rm -rf sui
git clone https://github.com/MystenLabs/sui.git
git checkout cff7a37e5c9b6bba1c82ff184657963a3ddba0e6
mkdir -p $HOME/sui/target/release/
# cd $HOME/sui
# git remote add upstream https://github.com/MystenLabs/sui
# git fetch upstream
# git checkout -B devnet --track upstream/devnet
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем обновление"
echo "-----------------------------------------------------------------------------"
# cargo build --release
version=0.7.0
wget -O $HOME/sui/target/release/sui https://doubletop-bin.ams3.digitaloceanspaces.com/sui/$version/sui
wget -O $HOME/sui/target/release/sui-node https://doubletop-bin.ams3.digitaloceanspaces.com/sui/$version/sui-node
wget -O $HOME/sui/target/release/sui-faucet https://doubletop-bin.ams3.digitaloceanspaces.com/sui/$version/sui-faucet
sudo chmod +x $HOME/sui/target/release/{sui,sui-node,sui-faucet}
sudo mv $HOME/sui/target/release/{sui,sui-node,sui-faucet} /usr/bin/
sudo systemctl restart sui
echo "-----------------------------------------------------------------------------"
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
