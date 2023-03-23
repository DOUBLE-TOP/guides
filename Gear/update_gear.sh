#!/bin/bash


source $HOME/.profile
sudo systemctl stop gear
/root/gear purge-chain -y

wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz
sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /root
rm gear-nightly-linux-x86_64.tar.xz


sudo systemctl start gear

sleep 15

sed -i "s/gear-node/gear/" "/etc/systemd/system/gear.service"

sudo systemctl daemon-reload
sudo systemctl stop gear
cd /root/.local/share/gear/chains
mkdir -p gear_staging_testnet_v6/network/

sudo cp gear_staging_testnet_v6/network/secret_ed25519 gear_staging_testnet_v7/network/secret_ed25519  &>/dev/null

sudo sed -i 's/telemetry\.postcapitalist\.io/telemetry.doubletop.io/g' /etc/systemd/system/gear.service

sudo systemctl daemon-reload
sudo systemctl restart gear
