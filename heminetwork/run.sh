#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

PRIVATE_KEY=$(cat $HOME/heminetwork/popm-address.json | jq ".private_key")

# Проверка, имеет ли переменная значение
if [ -z "$PRIVATE_KEY" ]; then
    echo "Введите приватный ключ для запуска майнера"
    read PRIVATE_KEY
fi

sudo tee /etc/systemd/system/hemi.service > /dev/null <<EOF
[Unit]
Description=Hemi miner
After=network.target

[Service]
User=$USER
Environment="POPM_BTC_PRIVKEY=$PRIVATE_KEY"
Environment="POPM_STATIC_FEE=4000"
Environment="POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public"
WorkingDirectory=$HOME/heminetwork
ExecStart=$HOME/heminetwork/popmd
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable hemi &>/dev/null
sudo systemctl daemon-reload
sudo systemctl start hemi

echo "Hemi майнер успешно запущен"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u hemi -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"