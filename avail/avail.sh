#!/bin/bash

# Проверяем, запущена ли сессия tmux с именем "avail"
if tmux has-session -t avail 2>/dev/null; then
  echo "Останавливаем сессию tmux 'avail'..."
  tmux kill-session -t avail
fi

# Создаём сервисный файл для systemd
SERVICE_FILE="/etc/systemd/system/avail-light.service"
CONFIG_FILE="$HOME/.avail/config/config.yml"
sed -i "/full_node_ws/d" "$CONFIG_FILE"
sed -i "/confidence/d" "$CONFIG_FILE"
echo "full_node_ws=['wss://rpc-goldberg.sandbox.avail.tools:443','wss://avail-goldberg.public.blastapi.io:443','wss://lc-rpc-goldberg.avail.tools:443/ws','wss://avail-goldberg-rpc.lgns.xyz:443/ws']" >> "$CONFIG_FILE"
echo "confidence=80.0" >> "$CONFIG_FILE"

# Проверяем, существует ли уже файл сервиса и удаляем его, если он есть
if [ -f "$SERVICE_FILE" ]; then
    echo "Удаляем старый сервисный файл..."
    sudo rm "$SERVICE_FILE"
fi

echo "Создаем новый сервисный файл..."

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

cat <<EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0

[Service]
User=$USER
ExecStart=$HOME/.avail/bin/avail-light --config $HOME/.avail/config/config.yml --identity $HOME/.avail/identity/identity.toml
Restart=always
RestartSec=120
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

echo "Перезагружаем конфигурацию systemd и запускаем сервис..."

# Перезагружаем systemd, чтобы учесть новый сервис
sudo systemctl daemon-reload

# Включаем сервис, чтобы он запускался при старте системы
sudo systemctl enable avail-light.service

# Запускаем сервис
sudo systemctl restart avail-light.service

echo "Сервис 'avail-light' успешно запущен."
