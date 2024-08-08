#!/bin/bash

function colors {
  GREEN="\e[32m"
  YELLOW="\e[33m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function stop_docker {
    echo -e "${YELLOW}Останавливаем текущий докер контейнер${NORMAL}"
    docker stop scout
}

function update_config {
    echo -e "${YELLOW}Обновляем конфигурацию с новым портом${NORMAL}"
    sed -i 's/PORT=3001/PORT=3002/g' $HOME/chasm-network/.env
    sed -i 's/3001/3002/g' $HOME/chasm-network/.env
}

function start_docker {
    echo -e "${YELLOW}Запускаем докер контейнер с новым портом${NORMAL}"
    docker rm scout
    docker run -d --restart=always --env-file $HOME/chasm-network/.env -p 3002:3002 --name scout chasmtech/chasm-scout
}

function output {
    echo -e "${YELLOW}Миграция завершена. Для проверки логов используйте команду:${NORMAL}"
    echo -e "docker logs -f scout --tail=100"
    echo -e "${YELLOW}Для перезапуска контейнера используйте команду:${NORMAL}"
    echo -e "docker restart scout"
}

colors
line
stop_docker
line
update_config
line
start_docker
line
output
line
echo "Миграция завершена. Нода работает на порте 3002"
line
