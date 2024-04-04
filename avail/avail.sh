#!/bin/bash

# Проверяем, запущена ли сессия tmux с именем "avail"
if tmux has-session -t avail 2>/dev/null; then
  echo "Останавливаем сессию tmux 'avail'..."
  tmux kill-session -t avail
fi

# Создаём сервисный файл для systemd
SERVICE_FILE="/etc/systemd/system/avail-light.service"

# Проверяем, существует ли уже файл сервиса и удаляем его, если он есть
if [ -f "$SERVICE_FILE" ]; then
    echo "Удаляем старый сервисный файл..."
    sudo rm "$SERVICE_FILE"
fi

echo "Создаем новый сервисный файл..."

chmod +x $HOME/.avail/bin/avail-light

cat <<EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0

[Service]
User=av
ExecStart=$HOME/.avail/bin/avail-light --network goldberg --config \$HOME/.avail/config/config.yml --identity \$HOME/.avail/identity/identity.toml
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
