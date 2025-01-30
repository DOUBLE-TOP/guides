#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update -y
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды"
echo "-----------------------------------------------------------------------------"

mkdir -p $HOME/pipe_backup

if systemctl list-units --type=service | grep -q "dcdnd.service"; then
    cp -r $HOME/.permissionless $HOME/pipe_backup

    sudo systemctl stop dcdnd
    sudo systemctl disbale dcdnd
    rm -rf /etc/systemd/system/dcdnd.service
    rm -rf $HOME/opt/dcdn
    rm -rf $HOME/.permissionless
fi

echo "Введите POP URL: "
read POP

echo "Введите адрес кошелька соланы: "
read PUB_KEY

cd $HOME
sudo mkdir -p $HOME/opt/dcdn/download_cache

sudo wget -O $HOME/opt/dcdn/pop "$POP"

sudo chmod +x $HOME/opt/dcdn/pop
sudo ln -s $HOME/opt/dcdn/pop /usr/local/bin/pop -f

sudo tee /etc/systemd/system/pop.service > /dev/null << EOF
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
ExecStart=$HOME/opt/dcdn/pop --ram=4 --pubKey $PUB_KEY --max-disk 100 --cache-dir $HOME/opt/dcdn/download_cache
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

sudo systemctl daemon-reload
sudo systemctl enable pop
sudo systemctl start pop

cp $HOME/opt/dcdn/node_info.json $HOME/pipe_backup/node_info.json

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -f -u pop"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
