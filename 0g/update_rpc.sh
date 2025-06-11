#!/bin/bash

echo "-----------------------------------------------------------------------------"
echo "Обновление до версии 1.2.0"
echo "-----------------------------------------------------------------------------"

sudo systemctl stop 0gchaind.service || true
sudo systemctl stop geth.service || true

echo "Скачиваем и распаковываем архив"
cd $HOME
source .profile
wget https://github.com/0glabs/0gchain-NG/releases/download/v1.2.0/galileo-v1.2.0.tar.gz
tar -xzf galileo-v1.2.0.tar.gz -C "$HOME" >/dev/null 2>&1
rm galileo-v1.2.0.tar.gz
sudo chmod +x $HOME/galileo-v1.2.0/bin/geth
sudo chmod +x $HOME/galileo-v1.2.0/bin/0gchaind

echo "Обновляем бинарники"
sudo cp $HOME/galileo-v1.2.0/bin/geth $HOME/go/bin/geth
sudo cp $HOME/galileo-v1.2.0/bin/0gchaind $HOME/go/bin/0gchaind

echo "Перезапускаем сервисы"
sudo systemctl restart geth.service
sudo systemctl restart 0gchaind.service

echo "Текущая версия:"
0gchaind version

echo "RPC Node успешно обновлена"
echo "-----------------------------------------------------------------------------"