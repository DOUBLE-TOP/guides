#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем переменные"
echo "-----------------------------------------------------------------------------" 
read -p "Введите адрес EVM кошелька (MM): " BEVM_NAME
    if [ -z "$BEVM_NAME" ]; then
    echo "Адрес кошелька не введён, повторите запуск!"
    exit 1
    fi
    echo "Ваш ник в телеметрии: $BEVM_NAME"
sleep 1
echo 'export BEVM_NAME='$BEVM_NAME >> $HOME/.profile
source $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Обновляем пакеты и устанавливаем зависимости"
echo "-----------------------------------------------------------------------------"
sudo apt update && apt upgrade -y
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh) &>/dev/null
echo "-----------------------------------------------------------------------------"
cd $HOME
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем ноду"
echo "-----------------------------------------------------------------------------"
wget -O bevm https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04 && chmod +x bevm
cp bevm /usr/bin/
sudo tee /etc/systemd/system/bevmd.service > /dev/null << EOF
[Unit]
Description=BTClayer2 Node
After=network-online.target
StartLimitIntervalSec=0
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=/usr/bin/bevm \
--port=20333 \
--chain=testnet --name="$BEVM_NAME" \
--pruning=archive \
--telemetry-url "wss://telemetry.bevm.io/submit 0" \
--telemetry-url "wss://telemetry.doubletop.io/submit 0" \
--bootnodes="/ip4/159.89.206.4/tcp/30333/ws/p2p/12D3KooWC1try3KoM3WeKMRjSiKMRxE9a4uws9S6tiy2anfKWTpi" \
--bootnodes="/ip4/84.247.142.25/tcp/30333/ws/p2p/12D3KooWPYFTMtVr12v7YWjVVoedhnpkktYVPG26U4hbD8vyfQpK" \
--bootnodes="/ip4/159.89.206.4/tcp/30333/ws/p2p/12D3KooWC1try3KoM3WeKMRjSiKMRxE9a4uws9S6tiy2anfKWTpi" \
--bootnodes="/ip4/84.247.177.64/tcp/30333/ws/p2p/12D3KooWKi8miRfBoKz87bKRaUr58QUVFSh2ZA8GqwkL1pxSWuip" \
--bootnodes="/ip4/84.247.174.227/tcp/30333/ws/p2p/12D3KooWBrCnzUjgEkT3VZuLUJ8JPxHmwRq8nZ5CwbL6LG8oNF98" \
--bootnodes="/ip4/84.247.170.13/tcp/30333/ws/p2p/12D3KooWL1VtfpTyqLsWpxYi6HVfNAHUjqyiXfLG2hwCf6BHtgUR" \
--bootnodes="/ip4/103.171.85.19/tcp/30333/ws/p2p/12D3KooWSb18ru71zhZ71qxoSnHR7PSi2hNPx3UFtadvZisG3aEQ" \
--bootnodes="/ip4/18.222.166.234/tcp/10000/ws/p2p/12D3KooWR1DNEVVWMaRJVfAkXTyZAZgnN159hNcPTooCSwMv4zbx

[Install]
WantedBy=multi-user.target
EOF
echo "-----------------------------------------------------------------------------"
echo "Запускаем ноду BEVM"
echo "-----------------------------------------------------------------------------"
sudo systemctl daemon-reload
sudo systemctl enable bevmd
sudo systemctl start bevmd
echo "-----------------------------------------------------------------------------"
echo "Нода запущена"
echo "-----------------------------------------------------------------------------"


# Удалить ноду
# sudo systemctl stop bevmd
# sudo systemctl disable bevmd
# rm -rf /etc/systemd/system/bevmd.service
# sudo systemctl daemon-reload
# rm -rf /usr/bin/bevm
# rm -rf .local/share/bevm/