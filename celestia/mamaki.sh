#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $CELESTIA_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " CELESTIA_NODENAME
fi
sleep 1
CELESTIA_CHAIN="mamaki"
echo 'export CELESTIA_CHAIN='$CELESTIA_CHAIN >> $HOME/.profile
echo 'export CELESTIA_NODENAME='$CELESTIA_NODENAME >> $HOME/.profile
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
cd
git clone https://github.com/celestiaorg/celestia-app.git &>/dev/null
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd $HOME/celestia-app/
git fetch &>/dev/null
git checkout v0.5.2 &>/dev/null
make install &>/dev/null
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
celestia-appd init $CELESTIA_NODENAME --chain-id $CELESTIA_CHAIN &>/dev/null
celestia-appd config chain-id $CELESTIA_CHAIN
celestia-appd config keyring-backend test
wget -O $HOME/.celestia-app/config/genesis.json "https://github.com/celestiaorg/networks/raw/master/mamaki/genesis.json" &>/dev/null

peers=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/peers.txt | tr -d '\n' | head -c -1) && echo $peers
sed -i.bak -e "s/^persistent-peers *=.*/persistent-peers = \"$peers\"/" $HOME/.celestia-app/config/config.toml &>/dev/null

bpeers="f0c58d904dec824605ac36114db28f1bf84f6ea3@144.76.112.238:26656"
sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$bpeers\"/" $HOME/.celestia-app/config/config.toml >/dev/null

sed -i.bak -e "s/^timeout-commit *=.*/timeout-commit = \"25s\"/" $HOME/.celestia-app/config/config.toml &>/dev/null
sed -i.bak -e "s/^skip-timeout-commit *=.*/skip-timeout-commit = false/" $HOME/.celestia-app/config/config.toml &>/dev/null
sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml &>/dev/null

sed -i 's/pruning = "default"/pruning = "custom"/g' $HOME/.celestia-app/config/app.toml &>/dev/null
sed -i 's/pruning-keep-recent = "0"/pruning-keep-recent = "100"/g' $HOME/.celestia-app/config/app.toml &>/dev/null
sed -i 's/pruning-keep-every = "0"/pruning-keep-every = "0"/g' $HOME/.celestia-app/config/app.toml &>/dev/null
sed -i 's/pruning-interval = "0"/pruning-interval = "10"/g' $HOME/.celestia-app/config/app.toml &>/dev/null

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd.service
[Unit]
  Description=Celestia-appd
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which celestia-appd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-appd &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart celestia-appd

echo "Validator Node $CELESTIA_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
