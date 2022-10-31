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
wget -O $HOME/tfsc/tfsc  https://uscloudmedia.s3.us-west-2.amazonaws.com/transformers/test/tfs_v0.9.0_90252d5_devnet
chmod +x $HOME/tfsc/tfsc
line
echo -e "${GREEN}Конфигурируем и запускаем tfsc${NORMAL}"
line
tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc'
sleep 5
pkill -9 tfsc
PUB_IP=$(wget -qO- eth0.me);wget -qO- pastebin.com/raw/MfS126mf|sed 's#\"ip\": \"pub_ip\"#\"ip\": '\"${PUB_IP}\"'#' > config.json
sed -i "s/OFF/INFO/" "$HOME/tfsc/config.json"
tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
line
echo -e "${GREEN}Установка завершена успешно, переходим к следующему пункту гайда${NORMAL}"
