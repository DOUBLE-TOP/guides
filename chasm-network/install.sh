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

function install_docker {
    if ! type "docker" > /dev/null; then
        echo -e "${YELLOW}Устанавливаем докер${NORMAL}"
        bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
    else
        echo -e "${YELLOW}Докер уже установлен. Переходим на следующий шаг${NORMAL}"
    fi
}

function prepare_files {
    echo -e "${YELLOW}Подготавливаем файлы конфига${NORMAL}"
    if [ ! -d "$HOME/chasm-network" ]; then
        rm -rf $HOME/chasm-network
    fi
    mkdir -p $HOME/chasm-network && cd $HOME/chasm-network
    read -p "Введите Scout имя" SCOUT_NAME
    read -p "Введите Scout UID" SCOUT_UID
    read -p "Введите Scout Webhook API ключ" WEBHOOK_API_KEY
    read -p "Введите GROQ API ключ" GROQ_API_KEY

    sudo tee $HOME/chasm-network/.env > /dev/null <<EOF
PORT=3001
LOGGER_LEVEL=debug

ORCHESTRATOR_URL=https://orchestrator.chasm.net
SCOUT_NAME=$SCOUT_NAME
SCOUT_UID=$SCOUT_UID
WEBHOOK_API_KEY=$WEBHOOK_API_KEY
WEBHOOK_URL=http://$(curl -s http://checkip.amazonaws.com):3001

# Chosen Provider (groq, openai)
PROVIDERS=groq
MODEL=gemma2-9b-it
GROQ_API_KEY=$GROQ_API_KEY
EOF
}

function run_docker {
    echo -e "${YELLOW}Запускаем докер контейнер для валидатора${NORMAL}"
    docker pull chasmtech/chasm-scout:latest
    if [ ! "$(docker ps -q -f name=^scout$)" ]; then
        if [ "$(docker ps -aq -f status=exited -f name=^frame$)" ]; then
            echo -e "${YELLOW}Докер контейнер уже существует в статусе exited. Удаляем его и запускаем заново${NORMAL}"
            docker rm -f scout
        fi
    fi
    cd $HOME/chasm-network
    docker run -d --restart=always --env-file ./.env -p 3001:3001 --name scout chasmtech/chasm-scout
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
prepare_files
line
install_docker
line
run_docker
line
output
line
echo "Wish lifechange case with DOUBLETOP"
line