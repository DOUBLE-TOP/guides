#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  YELLOW="\e[33m"
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
    echo -e "${YELLOW}Введите имя ноды(придумайте)${NORMAL}"
    line
    read AVAIL_NODENAME
    source $HOME/.profile
    fi
}

function install_main_tools {
    echo -e "${YELLOW}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
}

function wget_bin {
    echo -e "${YELLOW}Скачивание бинарников:${NORMAL}"
    ubuntu_version=$(lsb_release -rs)
    # Проверить версию и выполнить соответствующие действия
    if [ "$ubuntu_version" == "20.04" ]; then
        # Версия Ubuntu 20.04
        echo "Установка на Ubuntu 20.04"
        sudo wget https://doubletop-bin.ams3.digitaloceanspaces.com/avail/v1.7.3/avail-light -O /usr/bin/avail &>/dev/null
        sudo chmod +x /usr/bin/avail
    elif [ "$ubuntu_version" == "22.04" ]; then
        # Версия Ubuntu 22.04
        echo "Установка на Ubuntu 22.04"
        sudo wget https://github.com/availproject/avail-light/releases/download/v1.7.3/avail-light-linux-amd64.tar.gz &>/dev/null
        tar -xvf avail-light-linux-amd64.tar.gz
        rm -f avail-light-linux-amd64.tar.gz*
        sudo mv avail-light-linux-amd64 /usr/bin/avail
        sudo chmod +x /usr/bin/avail
    else
        # Другая версия Ubuntu
        echo "Данная версия Ubuntu ($ubuntu_version) не поддерживается"
    fi

}

function wget_chainspec {
    echo -e "${YELLOW}Скачивание конфигурции сети:${NORMAL}"
    mkdir -p $HOME/.avail
    wget -O $HOME/.avail/config.yaml "https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/avail/config.yaml" &>/dev/null
}

function create_systemd {
    echo -e "${YELLOW}Создание сервиса systemd:${NORMAL}"
    sudo tee <<EOF >/dev/null /etc/systemd/system/avail.service
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
--config $HOME/.avail/config.yaml \
--network goldberg
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable avail
sudo systemctl restart avail
}

function output {
    echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "journalctl -n 100 -f -u avail -o cat"
    echo -e "${YELLOW}Для перезапуска выполняем команду:${NORMAL}"
    echo -e "sudo systemctl restart avail"
}

function main {
    colors
    logo
    line
    install_main_tools
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