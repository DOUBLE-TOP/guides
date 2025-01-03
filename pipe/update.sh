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
    echo "Ошибка: Введите оба URL."
    exit 1
fi

sudo systemctl stop dcdnd

sudo rm -f $HOME/opt/dcdn/pipe-tool
sudo rm -f $HOME/opt/dcdn/dcdnd


sudo curl -L "$PIPE" -o $HOME/opt/dcdn/pipe-tool
sudo curl -L "$DCDND" -o $HOME/opt/dcdn/dcdnd

sudo chmod +x $HOME/opt/dcdn/pipe-tool
sudo chmod +x $HOME/opt/dcdn/dcdnd


echo "-----------------------------------------------------------------------------"
echo "Авторизация и регистрация токена"
echo "-----------------------------------------------------------------------------"

pipe-tool login --node-registry-url="https://rpc.pipedev.network"
pipe-tool generate-registration-token --node-registry-url="https://rpc.pipedev.network"

sudo systemctl daemon-reload
sudo systemctl start dcdnd

pipe-tool list-nodes --node-registry-url="https://rpc.pipedev.network"

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -f -u dcdnd"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
