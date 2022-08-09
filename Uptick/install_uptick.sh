#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $UPTICK_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " UPTICK_NODENAME
fi
sleep 1
UPTICK_CHAIN="uptick_7776-1"
echo 'export UPTICK_CHAIN='$UPTICK_CHAIN >> $HOME/.profile
echo 'export UPTICK_NODENAME='$UPTICK_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
git clone https://github.com/UptickNetwork/uptick.git &>/dev/null
cd uptick &>/dev/null
make install &>/dev/null
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
uptickd config chain-id augusta-1
uptickd init $UPTICK_NODENAME --chain-id $UPTICK_CHAIN &>/dev/null
wget -O $HOME/.uptickd/config/genesis.json "https://raw.githubusercontent.com/kuraassh/uptick-testnet/main/uptick_7776-1/genesis.json" &>/dev/null
SEEDS=`curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7776-1/seeds.txt | awk '{print $1}' | paste -s -d, -` &>/dev/null
PEERS=`curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7776-1/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -`

sed -i -e "s%^moniker *=.*%moniker = \"$UPTICK_NODENAME\"%; "\
"s%^seeds *=.*%seeds = \"$SEEDS\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"$PEERS\"%; "\
"s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; " $HOME/.uptickd/config/config.toml

sed -i -e "s%^indexer *=.*%indexer = \"null\"%; "\
"s%^pruning *=.*%pruning = \"custom\"%; "\
"s%^pruning-keep-recent *=.*%pruning-keep-recent =\"100\"%; "\
"s%^pruning-keep-every *=.*%pruning-keep-every =\"0\"%; "\
"s%^pruning-interval *=.*%pruning-interval =\"10\"%; " $HOME/.uptickd/config/app.toml
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/uptickd.service
[Unit]
  Description=UPTICK Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which uptickd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable uptickd &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart uptickd

echo "Validator Node $UPTICK_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
