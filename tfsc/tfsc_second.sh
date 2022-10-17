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
mkdir -p $HOME/tfsc_second
cd $HOME/tfsc_second/
wget -O $HOME/tfsc_second/tfsc  https://uscloudmedia.s3.us-west-2.amazonaws.com/transformers/test/ttfs_v0.8.0_76a6414_devnet
chmod +x $HOME/tfsc_second/tfsc
line
echo -e "${GREEN}Конфигурируем и запускаем tfsc${NORMAL}"
line
tmux new-session -d -s tfsc_second 'cd $HOME/tfsc_second/ && $HOME/tfsc_second/tfsc'
sleep 5
pkill -9 tfsc_second
PUB_IP=$(wget -qO- eth0.me);wget -qO- pastebin.com/raw/MfS126mf|sed 's#\"ip\": \"pub_ip\"#\"ip\": '\"${PUB_IP}\"'#' > config.json
sed -i "s/OFF/INFO/" "$HOME/tfsc_second/config.json"
tmux new-session -d -s tfsc_second 'cd $HOME/tfsc_second/ && $HOME/tfsc_second/tfsc -m'
line
echo -e "${GREEN}Установка завершена успешно, переходим к следующему пункту гайда${NORMAL}"
