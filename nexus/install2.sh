#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add riscv32i-unknown-none-elf

sudo apt install -y protobuf-compiler

source .profile

SERVICE_NAME="nexus.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
LOG_FILE="/var/log/nexus.log"
LOGROTATE_CONF="/etc/logrotate.d/nexus"
HOME_DIR="$HOME"
read -p "Введите NODE ID: " NODE_ID

# удаляем сервис если уже стоит
if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm "$SERVICE_FILE"
    fi
    > "$LOG_FILE"
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi


# Создаем systemd сервис
cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Nexus Service
After=network.target

[Service]
User=root
WorkingDirectory=$HOME_DIR
ExecStart=/bin/bash -c 'source /root/.profile && nexus-network start --node-id $NODE_ID'
Restart=always
RestartSec=5
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start "$SERVICE_NAME"

# Настраиваем Logrotate
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
fi
if [ -f "$LOGROTATE_CONF" ]; then
    echo "Logrotate уже настроен."
else
    # Create logrotate config
    sudo tee "$LOGROTATE_CONF" > /dev/null <<EOF
$LOG_FILE {
    daily
    rotate 2
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF

    # Запускаем вручную  logrotate
    logrotate -f "$LOGROTATE_CONF" &>/dev/null
fi

echo "Установка Nexus завершена. LogRotate настроен."
echo "Смотреть логи можно командой: tail -n 20 -f $LOG_FILE"
