#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
#if [ ! $BAZUKA_DISCORD ]; then
#	read -p "Введите discord handle(Например:KURASH#7375): " BAZUKA_DISCORD
#fi
#echo 'Ваш дискорд: ' $BAZUKA_DISCORD
#sleep 1
#echo 'export BAZUKA_KEY='$BAZUKA_DISCORD >> $HOME/.bash_profile

source $HOME/.profile
source $HOME/.bash_profile

sudo systemctl stop bazuka
#rm -rf $HOME/.bazuka-debug
#rm -rf $HOME/.bazuka.yaml

cd bazuka
git pull origin master
cargo build
cargo install --path .
rm -f /usr/local/bin/bazuka
# rm -rf $HOME/.bazuka-debug
sudo mv $HOME/bazuka/target/debug/bazuka /usr/local/bin/

#bazuka init --seed '"$BAZUKA_KEY"' --network chaos --node 127.0.0.1:8765

#sudo tee <<EOF >/dev/null /etc/systemd/system/bazuka.service
#[Unit]
#Description=Zeeka node
#After=network.target

#[Service]
#User=$USER
#ExecStart=`RUST_LOG=info which bazuka` node --listen 0.0.0.0:8765 --external $(wget -qO- eth0.me):8765 --network chaos --db $HOME/.bazuka-debug --bootstrap 152.228.155.120:8765 --bootstrap 5.161.152.123:8765 --bootstrap 65.108.201.41:8765 --bootstrap 185.213.25.229:8765 --bootstrap 45.88.106.199:8765 --bootstrap 148.251.1.124:8765 --bootstrap 195.54.41.115:8765 --bootstrap 195.54.41.130:8765 --discord-handle "$BAZUKA_DISCORD"
#Restart=on-failure
#RestartSec=3
#LimitNOFILE=65535

#[Install]
#WantedBy=multi-user.target
#EOF

#sudo systemctl daemon-reload
sudo systemctl restart bazuka

echo "-----------------------------------------------------------------------------"
echo "Нода Обновлена"
echo "-----------------------------------------------------------------------------"
