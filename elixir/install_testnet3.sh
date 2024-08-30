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
    if [ ! -d "$HOME/elixir" ]; then
        rm -rf $HOME/elixir
    fi

    docker rm -f ev &>/dev/null

    mkdir -p $HOME/elixir && cd $HOME/elixir

    STRATEGY_EXECUTOR_IP_ADDRESS=$(hostname -I | cut -d' ' -f1)
    read -p "Введите имя вашей ноды(это имя будет отображаться на дашбордах) " STRATEGY_EXECUTOR_DISPLAY_NAME
    read -p "Введите адрес кошелька(этот кошелек будет использоваться для ревардов) " STRATEGY_EXECUTOR_BENEFICIARY
    read -p "Введите приватный ключ с предыдущего пункта. Приватный ключ НЕ должен содержать приставку 0x " SIGNER_PRIVATE_KEY

    sudo tee $HOME/elixir/.env > /dev/null <<EOF
ENV=testnet-3

STRATEGY_EXECUTOR_IP_ADDRESS=$STRATEGY_EXECUTOR_IP_ADDRESS
STRATEGY_EXECUTOR_DISPLAY_NAME=$STRATEGY_EXECUTOR_DISPLAY_NAME
STRATEGY_EXECUTOR_BENEFICIARY=$STRATEGY_EXECUTOR_BENEFICIARY
SIGNER_PRIVATE_KEY=$SIGNER_PRIVATE_KEY
EOF
}

function run_docker {
    echo -e "${YELLOW}Запускаем докер контейнер для валидатора${NORMAL}"
    docker pull elixirprotocol/validator:v3
    if [ ! "$(docker ps -q -f name=^elixir$)" ]; then
        if [ "$(docker ps -aq -f status=exited -f name=^elixir$)" ]; then
            echo -e "${YELLOW}Докер контейнер уже существует в статусе exited. Удаляем его и запускаем заново${NORMAL}"
            docker rm -f elixir
        fi
    fi
    cd $HOME/elixir
    docker run -d --env-file $HOME/elixir/.env --name elixir --restart unless-stopped elixirprotocol/validator:v3
  }


function output {
    echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "docker logs -f elixir --tail=100"
    echo -e "${YELLOW}Для перезапуска выполняем команду:${NORMAL}"
    echo -e "docker restart elixir"
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