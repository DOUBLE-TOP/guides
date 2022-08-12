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
#rm -rf sui
#git clone https://github.com/MystenLabs/sui.git
cd $HOME/sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout -B devnet --track upstream/devnet
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем обновление"
echo "-----------------------------------------------------------------------------"
# cargo build --release
wget -O $HOME/sui/target/release/sui https://doubletop-bin.ams3.digitaloceanspaces.com/sui/0.6.4/sui
wget -O $HOME/sui/target/release/sui-node https://doubletop-bin.ams3.digitaloceanspaces.com/sui/0.6.4/sui-node
wget -O $HOME/sui/target/release/sui-faucet https://doubletop-bin.ams3.digitaloceanspaces.com/sui/0.6.4/sui-faucet
sudo mv $HOME/sui/target/release/{sui,sui-node,sui-faucet} /usr/bin/
sudo systemctl restart sui
echo "-----------------------------------------------------------------------------"
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
