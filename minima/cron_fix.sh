#!/bin/bash

function read_minima_id {
  if [ ! ${minima_id} ]; then
  echo "Введите свое minima id с личного кабинета"
  line
  read minima_id
  fi
}

function read_minima_service_name {
  if [ ! ${minima_service_name} ]; then
  echo "Введите имя сервиса minima(по умолчанию minima_9001)"
  line
  read minima_service_name
  fi
}

function read_minima_service_port {
  if [ ! ${minima_service_port} ]; then
  echo "Введите порт сервиса minima(по умолчанию 9002)"
  line
  read minima_service_port
  fi
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function minima_cron_sh {
  tee $HOME/minima_cron_${minima_service_name}.sh > /dev/null <<EOF
pkill -9 java
sudo systemctl restart ${minima_service_name}
sleep 30
curl -s 127.0.0.1:${minima_service_port}/incentivecash%20uid:$minima_id
sudo systemctl stop ${minima_service_name}
pkill -9 java
EOF
  chmod +x $HOME/minima_cron_${minima_service_name}.sh
}

function minima_cron {
  crontab -l > $HOME/minima_cron
  echo "@daily bash $HOME/minima_cron_${minima_service_name}.sh" >> $HOME/minima_cron
  crontab $HOME/minima_cron
  rm $HOME/minima_cron
  sudo systemctl restart cron
}

colors
line
logo
line
read_minima_id
read_minima_service_name
read_minima_service_port
line
minima_cron_sh
minima_cron
$HOME/minima_cron_${minima_service_name}.sh
