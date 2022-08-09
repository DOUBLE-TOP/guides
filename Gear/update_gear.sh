#!/bin/bash

wget https://builds.gear.rs/gear-nightly-linux-x86_64.tar.xz
sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /root
rm gear-nightly-linux-x86_64.tar.xz
$HOME/gear-node purge-chain -y
sudo systemctl restart gear
echo "Обновление завершено успешно"
