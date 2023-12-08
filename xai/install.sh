#!/bin/bash

# Запрашиваем приватный ключ
read -p "Введите приватный ключ от кошелька: " private_key

sudo apt update 

sudo apt install -y expect curl wget zip unzip jq

# Записываем ключ в файл .env
touch $HOME/xai/.env
echo "PRIVATE_KEY=$private_key" > $HOME/xai/.env
echo "HOME=$HOME" >> $HOME/xai/.env

# Создаем папку xai в домашней директории
mkdir -p $HOME/xai

# Создаем скрипт start.sh
cat << EOF > $HOME/xai/start.sh
#!/usr/bin/expect

set HOME ${HOME}

# Загрузка переменных окружения из файла .env
set env_file [open "\$HOME/xai/.env" r]
while {[gets \$env_file line] >= 0} {
    if {[regexp {^\s*([^#]+?)\s*=\s*(.+)\s*$} \$line -> key value]} {
        set ::env(\$key) \$value
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
# Путь к локальному файлу
local_file="$HOME/xai/sentry-node-cli-linux.zip"
remote_file="https://github.com/xai-foundation/sentry/releases/latest/download/sentry-node-cli-linux.zip"

# Проверка наличия локального файла и вычисление его MD5
if [ -f "$local_file" ]; then
    local_md5=$(md5sum "$local_file" | awk '{ print $1 }')
else
    local_md5=""
fi

# Получение MD5 удаленного файла
remote_md5=$(curl -sL "$remote_file" | md5sum | awk '{ print $1 }')

# Сравнение MD5
if [ "$local_md5" != "$remote_md5" ]; then
    # MD5 различаются, нужно скачать файл
    wget -O "$local_file" "$remote_file"
    unzip -o "$local_file" -d /usr/local/bin/
else
    # Файлы идентичны, обновление не требуется
    echo "Обновление не требуется. Файл уже обновлен."
fi
EOF

# Даем права на выполнение скриптам
chmod +x $HOME/xai/*.sh

cat << EOF > /etc/logrotate.d/xai
$HOME/xai/stdout.log {
    daily
    rotate 6
    compress
    missingok
    notifempty
    create 640 $USER $USER
}
EOF

# Перезагружаем конфигурацию logrotate
logrotate --force /etc/logrotate.d/xai

# Создаем systemd unit файл
cat << EOF > /etc/systemd/system/xai.service
[Unit]
Description=XAI Application Service
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=/bin/bash -c '$HOME/xai/start.sh >> $HOME/xai/stdout.log 2>&1'
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

