#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

if [ "$(lsb_release -si)" != "Ubuntu" ]; then
    echo "Скрипт установки работает только на операционной системе Ubuntu"
    exit 1
fi

# Get the version number
VERSION=$(lsb_release -rs)

# Check if version is 22.04 or higher
if [ "$(echo "$VERSION >= 22.04" | bc)" -eq 0 ]; then
    echo "Ubuntu версия должна быть 22.04 или выше. Обновите сначала версию своей ОС."
    exit 1
fi

sudo apt update && sudo apt upgrade -y && apt install curl -y

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды Nubit"
echo "-----------------------------------------------------------------------------"

curl -sLO http://nubit.sh/nubit-bin/nubit-node-linux-x86.tar

tar -xvf nubit-node-linux-x86.tar
mv nubit-node-linux-x86 $HOME/nubit-node
rm nubit-node-linux-x86.tar

NUBIT_PATH=$HOME/nubit-node
CONFIG_FILE=$NUBIT_PATH/config/config.json

NETWORK=$(grep -oP '"network": "\K[^"]+' $CONFIG_FILE)
NODE_TYPE=$(grep -oP '"node_type": "\K[^"]+' $CONFIG_FILE)
PEERS=$(grep -oP '"peers": "\K[^"]+' $CONFIG_FILE)
VALIDATOR_IP=$(grep -oP '"validator_ip": "\K[^"]+' $CONFIG_FILE)
GENESIS_HASH=$(grep -oP '"genesis_hash": "\K[^"]+' $CONFIG_FILE)
AUTH_TYPE=$(grep -oP '"auth_type": "\K[^"]+' $CONFIG_FILE)
START_TIMES=$(grep -oP '"times": \K[^,]+' $CONFIG_FILE)

if [ -z "$NETWORK" ] || [ -z "$NODE_TYPE" ] || [ -z "$PEERS" ] || [ -z "$VALIDATOR_IP" ] || [ -z "$GENESIS_HASH" ] || [ -z "$AUTH_TYPE" ] || [ -z "$START_TIMES" ]; then
  echo "Error reading config file"
  exit 1
fi

NUBIT_CUSTOM="${NETWORK}:${GENESIS_HASH}:${PEERS}"

BINARY=$NUBIT_PATH/bin/nubit

$BINARY $NODE_TYPE init  > $NUBIT_PATH/output.txt
mnemonic=$(grep -A 1 "MNEMONIC (save this somewhere safe!!!):" $NUBIT_PATH/output.txt | tail -n 1)
echo $mnemonic > $NUBIT_PATH/mnemonic.txt
rm $NUBIT_PATH/output.txt

$BINARY $NODE_TYPE auth $AUTH_TYPE

sed -i.bak "s/\"times\": 0/\"times\": 1/" $CONFIG_FILE


echo "-----------------------------------------------------------------------------"
echo "Переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/nubit.service
[Unit]
  Description=Nubit node
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$BINARY $NODE_TYPE start --p2p.network $NETWORK --core.ip $VALIDATOR_IP --rpc.addr 0.0.0.0
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=65535
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable nubit &>/dev/null
sudo systemctl daemon-reload
sudo systemctl start nubit

echo "-----------------------------------------------------------------------------"
echo "Light Nubit Node успешно установлена"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов:"
echo "journalctl -n 100 -f -u nubit -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
