#!/bin/bash


sudo systemctl stop gear-node
/root/gear-node purge-chain -y

wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz
sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /root
rm gear-nightly-linux-x86_64.tar.xz

sudo systemctl restart gear
echo "Обновление завершено успешно"
