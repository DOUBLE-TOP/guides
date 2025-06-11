#!/bin/bash

VERSION=$1

echo "-----------------------------------------------------------------------------"
echo "Обновление до версии $VERSION"
echo "-----------------------------------------------------------------------------"

sudo systemctl stop 0gchaind.service || true
sudo systemctl stop geth.service || true

cd $HOME
source .profile
rm -rf galileo galileo-$VERSION.tar.gz
wget -q https://github.com/0glabs/0gchain-NG/releases/download/$VERSION/galileo-$VERSION.tar.gz
tar -xzf galileo-$VERSION.tar.gz -C "$HOME"

echo "Обновляем бинарники"
chmod +x $HOME/galileo/bin/geth $HOME/galileo/bin/0gchaind
cp $HOME/galileo/bin/geth $HOME/go/bin/geth
cp $HOME/galileo/bin/0gchaind $HOME/go/bin/0gchaind

echo "Перезапускаем сервисы"
sudo systemctl restart geth.service
sudo systemctl restart 0gchaind.service

echo "Текущая версия:"
0gchaind version

echo "RPC Node успешно обновлена"
echo "-----------------------------------------------------------------------------"