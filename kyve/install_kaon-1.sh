#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $KYVE_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " KYVE_NODENAME
fi
sleep 1
KYVE_CHAIN="kaon-1"
echo 'export KYVE_CHAIN='$KYVE_CHAIN >> $HOME/.profile
echo 'export KYVE_NODENAME='$KYVE_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt upgrade -y
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget build-essential git jq make gcc tmux chrony lz4 unzip ncdu htop -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
cd $HOME
wget https://files.kyve.network/chain/v1.0.0-rc0/kyved_linux_amd64.tar.gz
tar -xvzf kyved_linux_amd64.tar.gz &>/dev/null
sudo chmod +x kyved
mkdir -p $HOME/go/bin
sudo mv kyved $HOME/go/bin/kyved
rm kyved_linux_amd64.tar.gz
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
kyved config chain-id $KYVE_CHAIN_ID
kyved config keyring-backend file
kyved init $KYVE_NODENAME --chain-id $KYVE_CHAIN_ID &>/dev/null
wget -O $HOME/.kyve/config/genesis.json https://snapshot.yeksin.net/kyve/genesis.json
wget -qO $HOME/.kyve/config/addrbook.json https://snapshot.yeksin.net/kyve/addrbook.json &>/dev/null
sed -i -e "s%^moniker *=.*%moniker = \"$KYVE_NODENAME\"%; "\
"s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; " $HOME/.kyve/config/config.toml
SEEDS=""
PEERS="bc8b5fbb40a1b82dfba591035cb137278a21c57d@52.59.65.9:26656,801fa026c6d9227874eeaeba288eae3b800aad7f@52.29.15.250:26656,78d76da232b5a9a5648baa20b7bd95d7c7b9d249@142.93.161.118:26656,b68e5131552e40b9ee70427879eb34e146ef20df@18.194.131.3:26656,59addee10822d8cfe2c4635a404ab67687357449@141.95.33.158:26651,bbb7a427e04d38c74f574f6f0162e1359b66b330@93.115.25.18:39656,7258cf2c1867cc5b997baa19ff4a3e13681f14f4@68.183.143.17:26656,430845649afaad0a817bdf36da63b6f93bbd8bd1@3.67.29.225:26656,e8c9a0f07bc34fb870daaaef0b3da54dbf9c5a3b@15.235.10.35:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kyve/config/config.toml
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0tkyve\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.kyve/config/config.toml
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/kyved.service
[Unit]
  Description=Kyve Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which kyved) start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=65535
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable kyved &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart kyved

echo "Validator Node $KYVE_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
