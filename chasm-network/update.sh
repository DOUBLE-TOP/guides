#!/bin/bash
function colors {
  GREEN="\e[32m"
  YELLOW="\e[33m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}


function run_docker {
    echo -e "${YELLOW}Запускаем докер контейнер для валидатора${NORMAL}"
    docker rm -f scout
    docker images | grep 'chasm-scout' | awk '{print $3}' | xargs docker rmi
    docker pull chasmtech/chasm-scout:0.0.6
    docker run -d --restart=always --env-file $HOME/chasm-network/.env -p 3002:3002 --name scout chasmtech/chasm-scout
}

function output {
    echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "docker logs -f scout --tail=100"
    echo -e "${YELLOW}Для перезапуска выполняем команду:${NORMAL}"
    echo -e "docker restart scout"
}

colors
line
logo
line
run_docker
line
output
line
echo "Wish lifechange case with DOUBLETOP"
line