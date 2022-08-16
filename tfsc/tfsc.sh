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


line
logo
line
echo -e "${GREEN}Устанавливаем тулзы${NORMAL}"
line
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/tools/main.sh)
line
echo -e "${GREEN}Скачиваем tfsc${NORMAL}"
line
mkdir -p $HOME/tfsc
cd $HOME/tfsc/
wget -O $HOME/tfsc/tfsc https://fastcdn.uscloudmedia.com/transformers/test/ttfsc_v0.2.0_681c2ec_devnet
chmod +x $HOME/tfsc/tfsc
line
echo -e "${GREEN}Конфигурируем и запускаем tfsc${NORMAL}"
line
tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc'
sleep 5
pkill -9 tfsc
IP=$(curl -s ifconfig.me)
sed -i "s/\ \ \ \ \"ip\"\:\ \".*"\,/\ \ \ \ \"ip\"\:\ \"$IP"\"\,/" "$HOME/tfsc/config.json"
sed -i "s/OFF/INFO/" "$HOME/tfsc/config.json"
tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
line
echo -e "${GREEN}Установка завершена успешно, переходим к следующему пункту гайда${NORMAL}"
