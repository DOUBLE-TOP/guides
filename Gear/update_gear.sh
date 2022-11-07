#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
#if [ -z $NODENAME_GEAR ]; then
#        read -p "Введите ваше имя ноды (придумайте, без спецсимволов - только буквы и цифры): " NODENAME_GEAR
#        echo 'export NODENAME='$NODENAME_GEAR >> $HOME/.profile
#fi
#echo 'Ваше имя ноды: ' $NODENAME_GEAR
#sleep 1

source $HOME/.profile
sudo systemctl stop gear
/root/gear-node purge-chain -y

echo "-----------------------------------------------------------------------------"
echo "Выполняем Обновление"
echo "-----------------------------------------------------------------------------"


wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz
sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /root
rm gear-nightly-linux-x86_64.tar.xz

#sudo tee <<EOF >/dev/null /etc/systemd/system/gear.service
#[Unit]
#Description=Gear Node
#After=network.target

#[Service]
#Type=simple
#User=$USER
#WorkingDirectory=$HOME
#ExecStart=$HOME/gear \
#        --name $NODENAME_GEAR \
#        --execution wasm \
#	--port 31333 \
#        --telemetry-url 'ws://telemetry-backend-shard.gear-tech.io:32001/submit 0' \
#	--telemetry-url 'wss://telemetry.postcapitalist.io/submit 0'
#Restart=always
#RestartSec=10
#LimitNOFILE=10000

#[Install]
#WantedBy=multi-user.target
#EOF

sudo systemctl stop gear-node
cd /root/.local/share/gear-node/chains
sudo cp gear_staging_testnet_v3/network/secret_ed25519 gear_staging_testnet_v4/network/secret_ed25519


sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl restart gear
echo "-----------------------------------------------------------------------------"
echo "Обновление завершено успешно"
echo "-----------------------------------------------------------------------------"
