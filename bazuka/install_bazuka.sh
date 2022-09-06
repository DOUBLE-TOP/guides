#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $BAZUKA_KEY ]; then
	read -p "Введите bip39 mnemonic: " BAZUKA_KEY
fi
echo 'Ваш ключ: ' $BAZUKA_KEY
sleep 1
echo 'export BAZUKA_KEY='$BAZUKA_KEY >> $HOME/.bash_profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt upgrade -y &>/dev/null
sudo apt install wget jq git libssl-dev cmake -y &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
source $HOME/.cargo/env
source $HOME/.profile
source $HOME/.bashrc
sleep 1
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
git clone https://github.com/zeeka-network/bazuka &>/dev/null
cd bazuka && git pull origin master && cargo build && cargo install --path .
sudo mv $HOME/bazuka/target/debug/bazuka /usr/local/bin/ &>/dev/null
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
bazuka init --seed '"$BAZUKA_KEY"' --network debug --node 127.0.0.1:8765

sudo tee <<EOF >/dev/null /etc/systemd/system/bazuka.service
[Unit]
Description=Zeeka node
After=network.target

[Service]
User=$USER
ExecStart=`RUST_LOG=info which bazuka` node --listen 0.0.0.0:8765 --external $(wget -qO- eth0.me):8765 --network debug --db ~/.bazuka-debug --bootstrap 5.161.152.123:8765 --bootstrap 65.108.201.41:8765 --bootstrap 185.213.25.229:8765 --bootstrap 45.88.106.199:8765 --bootstrap 148.251.1.124:8765 --bootstrap 195.54.41.115:8765 --bootstrap 195.54.41.130:8765
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo "Сервисные файлы созданы успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl daemon-reload
sudo systemctl enable bazuka &>/dev/null
sudo systemctl restart bazuka

echo "Нода добавлена в автозагрузку на сервере, запущена"
echo "-----------------------------------------------------------------------------"
