#!/bin/bash
#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

if [ ! $OMNIFLIX_NODENAME ]; then
	read -p "Введите имя ноды(1в1 как у вас назывался валидатор в Omniflix): " OMNIFLIX_NODENAME
fi
echo 'Ваше имя ноды: ' $OMNIFLIX_NODENAME
sleep 1
echo 'export OMNIFLIX_NODENAME='$OMNIFLIX_NODENAME >> $HOME/.profile


sudo apt update
sudo apt install curl -y
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash


source $HOME/.profile
sleep 1

git clone https://github.com/Omniflix/omniflixhub.git
cd omniflixhub
git checkout v0.2.1
make install

chain_id=flixnet-2
omniflixhubd init $OMNIFLIX_NODENAME --chain-id $chain_id
# omniflixhubd keys add $OMNIFLIX_NODENAME &>> $HOME/account.txt
#
# omniflixhubd add-genesis-account $OMNIFLIX_NODENAME 50000000uflix
#
# omniflixhubd gentx $OMNIFLIX_NODENAME 50000000uflix \
#   --pubkey=$(omniflixhubd tendermint show-validator) \
#   --chain-id="$chain_id" \
#   --moniker=$OMNIFLIX_NODENAME \
#   --details="$OMNIFLIX_NODENAME from DOUBLETOP" \
#   --commission-rate="0.10" \
#   --commission-max-rate="0.20" \
#   --commission-max-change-rate="0.01" \
#   --min-self-delegation="1"

sudo tee /etc/systemd/system/omniflixhubd.service > /dev/null <<EOF
[Unit]
Description=OmniFlixHub Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which omniflixhubd) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable omniflixhubd
#sudo systemctl start omniflixhubd
