#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление ноды"
echo "-----------------------------------------------------------------------------"

echo "Введите PIPE URL: "
read PIPE

echo "Введите DCDND URL: "
read DCDND

if [[ -z "$PIPE" || -z "$DCDND" ]]; then
    echo "Ошибка: Вы должны ввести оба URL."
    exit 1
fi

sudo systemctl stop dcdnd

sudo rm -f /opt/dcdn/pipe-tool
sudo rm -f /opt/dcdn/dcdnd


sudo curl -L "$PIPE" -o /opt/dcdn/pipe-tool
sudo curl -L "$DCDND" -o /opt/dcdn/dcdnd

sudo chmod +x /opt/dcdn/pipe-tool
sudo chmod +x /opt/dcdn/dcdnd

sudo systemctl daemon-reload
sudo systemctl restart dcdnd

echo "-----------------------------------------------------------------------------"
echo "Авторизация"
echo "-----------------------------------------------------------------------------"

/opt/dcdn/pipe-tool login --node-registry-url="https://rpc.pipedev.network"
/opt/dcdn/pipe-tool list-nodes --node-registry-url="https://rpc.pipedev.network"

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -f -u dcdnd"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
