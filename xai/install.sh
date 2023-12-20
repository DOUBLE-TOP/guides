#!/bin/bash

# Запрашиваем приватный ключ
read -p "Введите приватный ключ от кошелька: " private_key

sudo apt update 

sudo apt install -y expect curl wget zip unzip jq

# Создаем папку xai в домашней директории
mkdir -p $HOME/xai

# Записываем ключ в файл .env
touch $HOME/xai/.env
echo "PRIVATE_KEY=$private_key" > $HOME/xai/.env
echo "HOME=$HOME" >> $HOME/xai/.env



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
            send_user "Error detected, initiating service restart...\n"
            exec systemctl restart xai
            exit
        }
    }
}

# Завершение работы скрипта
expect eof
EOF

# Создаем скрипт update.sh
cat << 'EOF' > $HOME/xai/update.sh
#!/bin/bash

# Скачивание файла с помощью wget
wget https://github.com/xai-foundation/sentry/releases/latest/download/sentry-node-cli-linux.zip

unzip sentry-node-cli-linux.zip

mv sentry-node-cli-linux /usr/local/bin/sentry-node-cli-linux
rm -f sentry-node-cli-linux.zip
EOF

# Даем права на выполнение скриптам
chmod +x $HOME/xai/*.sh

# cat << EOF > /etc/logrotate.d/xai
# $HOME/xai/stdout.log {
#     daily
#     rotate 6
#     compress
#     missingok
#     notifempty
#     create 640 $USER $USER
# }
# EOF

# # Перезагружаем конфигурацию logrotate
# logrotate --force /etc/logrotate.d/xai

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

