#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " NODENAME
fi
echo 'Ваше имя ноды: ' $NODENAME
sleep 1
echo 'export NODENAME='$NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source $HOME/.profile &>/dev/null
source $HOME/.bashrc &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

if [ ! -d $HOME/Metaverse-Network/ ]; then
  git clone https://github.com/bit-country/Metaverse-Network.git &>/dev/null
fi
cd $HOME/Metaverse-Network
git checkout 372678324f5543e527591f68b128ff6919267558 &>/dev/null
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"

make init &>/dev/null
cargo build --release --features=with-tewai-runtime &>/dev/null
rm -rf Bit-Country-Blockchain &>/dev/null
rm -rf .local/share/bitcountry-node/chains/tewai_testnet/db/ &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/bitcountry.service
[Unit]
Description=Bitcountry Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/Metaverse-Network/target/release/metaverse-node --chain tewai --bootnodes /ip4/13.239.118.231/tcp/30344/p2p/12D3KooW9rDqyS5S5F6oGHYsmFjSdZdX6HAbTD88rPfxYfoXJdNU --name '$NODENAME' --telemetry-url 'wss://telemetry.polkadot.io/submit/ 0'
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

echo "Сервисные файлы созданы успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl daemon-reload
sudo systemctl enable bitcountry &>/dev/null
sudo systemctl restart bitcountry

echo "Нода добавлена в автозагрузку на сервере, запущена"
echo "-----------------------------------------------------------------------------"
