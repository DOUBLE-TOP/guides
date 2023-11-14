#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function get_nodename {
    if [ ! ${AVAIL_NODENAME} ]; then
    echo -e "${RED}Введите имя ноды(придумайте)${NORMAL}"
    line
    read AVAIL_NODENAME
    source $HOME/.profile
    fi
}

function install_main_tools {
    echo -e "${GREEN}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
}

function wget_bin {
    echo -e "${GREEN}Скачивание бинарников:${NORMAL}"
    wget https://github.com/availproject/avail/releases/download/v1.8.0.0/data-avail-linux-amd64.tar.gz
    tar -xvf data-avail-linux-amd64.tar.gz
    sudo mv data-avail-linux-amd64.tar.gz /usr/bin/avail
}

function wget_chainspec {
    echo -e "${GREEN}Скачивание конфигурции сети:${NORMAL}"
    mkdir -p $HOME/.avail && cd $HOME/.avail
    wget -O $HOME/.avail/chainspec.raw.json "https://kate.avail.tools/chainspec.raw.json"
    chmod 744 ~/.avail/chainspec.raw.json
}

function create_systemd {
    echo -e "${GREEN}Создание сервиса systemd:${NORMAL}"
    sudo tee <<EOF >/dev/null  /etc/systemd/system/avail.service > /dev/null << EOF
[Unit]
Description=Avail Node
After=network-online.target
StartLimitIntervalSec=0
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=/usr/bin/avail \
--base-path $HOME/.avail/data/ \
--chain $HOME/.avail/chainspec.raw.json \
--port 40333 \
--rpc-port 49933 \
--prometheus-port 49615 \
--validator \
--name '$AVAIL_NODENAME' \
--telemetry-url 'wss://telemetry.doubletop.io/submit 0' \
--telemetry-url 'wss://telemetry.avail.tools/submit 0' 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable avail
sudo systemctl restart avail
}

function output {
    echo -e "${GREEN}Нода установлена, идем проверять себя в телеметрии:${NORMAL}"
    echo -e "https://telemetry.avail.tools/#list/0x6f09966420b2608d1947ccfb0f2a362450d1fc7fd902c29b67c906eaa965a7ae"
    echo -e "${GREEN}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "journalctl -n 100 -f -u avail -o cat"
    echo -e "${GREEN}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "sudo systemctl restart avail"
}

function main {
    colors
    logo
    line
    install_main_tools
    line
    get_nodename
    line
    wget_bin
    line
    wget_chainspec
    line
    create_systemd
    line
    output
}

main