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
    if [ -d "$HOME/chasm-network" ]; then
        if [ "$(docker ps -q -f name=scout)" ]; then
            source $HOME/chasm-network/.env
            git clone https://github.com/ChasmNetwork/chasm-scout
                sudo tee $HOME/chasm-scout/dispute/.env > /dev/null <<EOF
LLM_API_KEY=$GROQ_API_KEY
LLM_BASE_URL=https://api.groq.com/openai/v1
MODELS=llama3-8b-8192,mixtral-8x7b-32768,gemma-7b-it,gemma2-9b-it
SIMULATION_MODEL=gemma2-9b-it
ORCHESTRATOR_URL=https://orchestrator.chasm.net
WEBHOOK_API_KEY=$WEBHOOK_API_KEY
MIN_CONFIDENCE_SCORE=0.5
EOF
        else
            echo "Контейнер Scout не запущен. Проверьте контейенер если вы устанавливали ноду."
            exit 1
        fi
    else
        echo "Cначала установите Скаут"
        exit 1
    fi
}

function run_docker {
    echo -e "${YELLOW}Запускаем Dispute Scout контейнер ${NORMAL}"
    cd $HOME/chasm-scout/dispute && docker compose up -d
}


function output {
    echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "docker logs -f dispute-app-1 --tail=100"
    echo -e "${YELLOW}Для перезапуска выполняем команду:${NORMAL}"
    echo -e "docker restart dispute-app-1"
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