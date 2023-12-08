#!/bin/bash

# Запрашиваем приватный ключ
read -p "Введите приватный ключ от кошелька: " private_key

# Записываем ключ в файл .env
echo "PRIVATE_KEY=$private_key" > $HOME/xai/.env

# Создаем папку xai в домашней директории
mkdir -p $HOME/xai

# Создаем скрипт start.sh
cat << 'EOF' > $HOME/xai/start.sh
#!/usr/bin/expect

# Загрузка переменных окружения из файла .env
set env_file [open "$HOME/xai/.env" r]
while {[gets $env_file line] >= 0} {
    if {[regexp {^\s*([^#]+?)\s*=\s*(.+)\s*$} $line -> key value]} {
        set ::env($key) $value
    }
}

# Запуск sentry-node-cli-linux с загруженными переменными окружения
spawn /usr/local/bin/sentry-node-cli-linux

# Ожидание загрузки оболочки
expect "Type \"help\" to display a list of actions."

# Бесконечный цикл
while {1} {
    # Выполнение команды внутри оболочки
    send "boot-operator\r"

    # Ожидание сообщения об успешной операции или ошибке
    expect {
        "Enter the private key of the operator:" {
            send "$::env(PRIVATE_KEY)\r"
        }
        "Error: missing revert data" {
            send_user "Error detected, exiting...\n"
            exit 0
        }
    }
}

# Завершение работы скрипта
expect eof
EOF

# Создаем скрипт update.sh
cat << 'EOF' > $HOME/xai/update.sh
#!/bin/bash

# Получение URL последнего релиза с помощью GitHub API и jq
release_url=$(curl -s https://api.github.com/repos/xai-foundation/sentry/releases/latest | jq -r '.assets[] | select(.name == "sentry-node-cli-linux.zip").browser_download_url')

# Проверка, что URL найден
if [ -z "$release_url" ]; then
    echo "Не удалось найти URL релиза."
    exit 1
fi

# Скачивание файла с помощью wget
wget "$release_url"

unzip sentry-node-cli-linux.zip

mv sentry-node-cli-linux /usr/local/bin/sentry-node-cli-linux
rm -f sentry-node-cli-linux.zip
EOF

# Даем права на выполнение скриптам
chmod +x $HOME/xai/start.sh
chmod +x $HOME/xai/update.sh

# Создаем systemd unit файл
cat << EOF > /etc/systemd/system/xai.service
[Unit]
Description=XAI Application Service
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=$HOME/xai
ExecStart=$HOME/xai/start.sh
ExecStop=/usr/bin/pkill -f start.sh
Restart=always
RestartSec=3
ExecStartPre=$HOME/xai/update.sh

[Install]
WantedBy=multi-user.target
EOF

# Перезагружаем конфигурацию systemd и включаем сервис
systemctl daemon-reload
systemctl enable xai.service

# Запускаем сервис
systemctl restart xai.service
