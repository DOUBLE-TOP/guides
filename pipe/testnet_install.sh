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
sudo apt install -y ca-certificates &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды"
echo "-----------------------------------------------------------------------------"

USERNAME="popcache"
LOGROTATE_FILE="/etc/logrotate.d/popcache"

if id "$USERNAME" &>/dev/null; then
    echo "Пользователь '$USERNAME' существует"
else
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "Пользователь '$USERNAME' создан."
fi
sudo usermod -aG sudo "$USERNAME"

sudo bash -c 'cat > /etc/sysctl.d/99-popcache.conf << "EOL"
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
EOL'

sudo sysctl --system

sudo bash -c 'cat > /etc/security/limits.d/popcache.conf << "EOL"
*    hard nofile 65535
*    soft nofile 65535
EOL'

sudo mkdir -p /opt/popcache
cd /opt/popcache

# DOWNLOAD binary here

# ask user questions and create config.json

sudo mkdir -p /opt/popcache/logs
sudo chown -R popcache:popcache /opt/popcache

SERVICE_NAME="popcache.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
# удаляем сервис если уже стоит
if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm "$SERVICE_FILE"
    fi
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi

echo "Создаем systemd сервис popcache."

sudo bash -c 'cat > /etc/systemd/system/popcache.service << "EOL"
[Unit]
Description=POP Cache Node
After=network.target

[Service]
Type=simple
User=popcache
Group=popcache
WorkingDirectory=/opt/popcache
ExecStart=/opt/popcache/pop
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=append:/opt/popcache/logs/stdout.log
StandardError=append:/opt/popcache/logs/stderr.log
Environment=POP_CONFIG_PATH=/opt/popcache/config.json

[Install]
WantedBy=multi-user.target
EOL'

sudo systemctl daemon-reexec
sudo systemctl daemon-reload

sudo systemctl enable popcache
sudo service popcache start
echo "Сервис создан и запущен."

sudo bash -c 'cat > "$LOGROTATE_FILE" << "EOL"
/opt/popcache/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 popcache popcache
    sharedscripts
    postrotate
        systemctl reload popcache >/dev/null 2>&1 || true
    endscript
}
EOL'
sudo mkdir -p /opt/popcache/logs
sudo chown -R "$USER:$GROUP" /opt/popcache/logs
echo "Ротация логов настроена."

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "tail -f /opt/popcache/logs/stderr.log"
echo "tail -f /opt/popcache/logs/stdout.log"
echo "sudo journalctl -u popcache"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
