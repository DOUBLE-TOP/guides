#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update -y
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

echo "-----------------------------------------------------------------------------"
echo "Установка ноды"
echo "-----------------------------------------------------------------------------"

echo "Введите PIPE URL: "
read PIPE

echo "Введите DCDND URL: "
read DCDND

cd $HOME
sudo mkdir -p $HOME/opt/dcdn

sudo wget -O $HOME/opt/dcdn/pipe-tool "$PIPE"
sudo wget -O $HOME/opt/dcdn/dcdnd "$DCDND"

sudo chmod +x $HOME/opt/dcdn/pipe-tool
sudo chmod +x $HOME/opt/dcdn/dcdnd

sudo ln -s $HOME/opt/dcdn/pipe-tool /usr/local/bin/pipe-tool -f
sudo ln -s $HOME/opt/dcdn/dcdnd /usr/local/bin/dcdnd -f

sudo tee /etc/systemd/system/dcdnd.service > /dev/null << EOF
[Unit]
Description=DCDN Node Service
After=network.target
Wants=network-online.target

[Service]
ExecStart=$(which dcdnd) \
                --grpc-server-url=0.0.0.0:8002 \
                --http-server-url=0.0.0.0:8003 \
                --node-registry-url="https://rpc.pipedev.network" \
                --cache-max-capacity-mb=1024 \
                --credentials-dir=/root/.permissionless \
                --allow-origin=*

Restart=always
RestartSec=5

LimitNOFILE=65536
LimitNPROC=4096

StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node

WorkingDirectory=$HOME/opt/dcdn

[Install]
WantedBy=multi-user.target
EOF

echo "-----------------------------------------------------------------------------"
echo "Авторизация и регистрация токена"
echo "-----------------------------------------------------------------------------"

pipe-tool login --node-registry-url="https://rpc.pipedev.network"
pipe-tool generate-registration-token --node-registry-url="https://rpc.pipedev.network"


sudo systemctl daemon-reload
sudo systemctl enable dcdnd
sudo systemctl restart dcdnd

pipe-tool generate-wallet --node-registry-url="https://rpc.pipedev.network" --key-path=$HOME/.permissionless/key.json
pipe-tool link-wallet --node-registry-url="https://rpc.pipedev.network" --key-path=$HOME/.permissionless/key.json

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -f -u dcdnd"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
