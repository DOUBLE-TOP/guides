#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git -y
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
}

function read_pass {
  if [ ! $DUSK_PASS ]; then
  echo -e "Введите(придумайте) пароль который будет использваться для кошелька"
  line_1
  read DUSK_PASS
  fi
  echo "export DUSK_PASS=123456" >> $HOME/.profile
  source $HOME/.profile
}

function install {
  curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dusk/itn-installer.sh | sudo sh
}

function configure {
rusk-wallet --password $DUSK_PASS create --seed-file $HOME/dusk_wallet.txt
sleep 5
rusk-wallet --password $DUSK_PASS export -d /opt/dusk/conf -n consensus.keys
sleep 5
echo "DUSK_CONSENSUS_KEYS_PASS=$DUSK_PASS" > /opt/dusk/services/dusk.conf
}

function run { 
  sudo tee <<EOF >/dev/null /etc/systemd/system/rusk.service
[Unit]
Description=DUSK Rusk
After=network.target
After=create_dusk_info.service

[Service]
Type=simple

Environment="RUST_BACKTRACE=full"
Environment="RUSK_PROFILE_PATH=/opt/dusk/rusk"

User=dusk
WorkingDirectory=/opt/dusk

ExecStartPre=!/bin/bash -c '/opt/dusk/bin/rusk recovery-keys >> /var/log/rusk_recovery.log'
ExecStartPre=!/bin/bash -c '/opt/dusk/bin/rusk recovery-state >> /var/log/rusk_recovery.log'
ExecStartPre=!/bin/bash -c '/opt/dusk/bin/check_consensus_keys.sh'
ExecStartPre=!/bin/bash -c '/opt/dusk/bin/detect_ips.sh > /opt/dusk/services/rusk.conf.default'
ExecStartPre=!/bin/bash -c 'chown -R dusk /opt/dusk/rusk/state'

EnvironmentFile=/opt/dusk/services/rusk.conf.default
EnvironmentFile=/opt/dusk/services/rusk.conf.user
EnvironmentFile=/opt/dusk/services/dusk.conf
EnvironmentFile=/root/.dusk/rusk-wallet/config.toml

ExecStart=/opt/dusk/bin/rusk \
            --http-listen-addr 127.0.0.1:8008 \
            --config /opt/dusk/conf/rusk.toml \
            --kadcast-bootstrap bootstrap1.testnet.dusk.network:9000 \
            --kadcast-bootstrap bootstrap2.testnet.dusk.network:9000

StandardOutput=append:/var/log/rusk.log
StandardError=append:/var/log/rusk.log

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды rusk: ${NORMAL}"
  echo -e "${RED}   systemctl stop rusk \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера rusk: ${NORMAL}"
  echo -e "${RED}   systemctl start rusk \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды rusk: ${NORMAL}"
  echo -e "${RED}   systemctl restart rusk \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды rusk выполняем команду: ${NORMAL}"
  echo -e "${RED}   tail -f /var/log/rusk.log \n ${NORMAL}"
  echo -e "${GREEN}Сохраните ваш мнемоник от кошелька в надежном месте. Он также сохранен в домашней директории в файле dusk_wallet.txt: ${NORMAL}"
  echo -e "${RED}"
  echo -e "##############################################################################"
  cat dusk_wallet.txt
  echo -e "${NORMAL}"
}

colors
line_1
logo
line_2
read_pass
line_2
echo -e "Установка tools, ufw"
line_1
install_tools
install_ufw
line_1
echo -e "Устанавливаем и конфигурируем ноду rusk"
line_1
install
line_1
configure
line_1
echo -e "Запускаем ноду rusk"
line_1
run
line_2
echo_info
line_2
