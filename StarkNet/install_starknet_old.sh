#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $ALCHEMY_KEY ]; then
	read -p "Введите ваш HTTP (ПРИМЕР: https://eth-goerli.alchemyapi.io/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN): " ALCHEMY_KEY
fi
echo 'Ваш ключ: ' $ALCHEMY_KEY
sleep 1
echo 'export ALCHEMY_KEY='$ALCHEMY_KEY >> $HOME/.bash_profile
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"

sudo apt update -y &>/dev/null
sudo apt install build-essential libssl-dev libffi-dev python3-dev screen git python3-pip python3.*-venv -y &>/dev/null
sudo apt-get install libgmp-dev -y &>/dev/null
pip3 install fastecdsa &>/dev/null
sudo apt-get install -y pkg-config &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
rustup default nightly &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

git clone --branch `curl https://api.github.com/repos/eqlabs/pathfinder/releases/latest -s | jq .name -r` https://github.com/eqlabs/pathfinder.git
cd pathfinder/py &>/dev/null
python3 -m venv .venv &>/dev/null
source .venv/bin/activate &>/dev/null
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip --use-pep517
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt --use-pep517
cargo build --release --bin pathfinder
sleep 2
source $HOME/.bash_profile &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/starknet.service
[Unit]
Description=StarkNet Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/pathfinder/py
Environment=PATH="$HOME/pathfinder/py/.venv/bin:\$PATH"
ExecStart=$HOME/pathfinder/target/release/pathfinder --ethereum.url $ALCHEMY_KEY
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

echo "Сервисные файлы созданы успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl enable starknet &>/dev/null
sudo systemctl restart starknet &>/dev/null

echo "Нода добавлена в автозагрузку на сервере, запущена"
echo "-----------------------------------------------------------------------------"
