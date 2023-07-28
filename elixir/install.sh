#!/bin/bash

function env {
    if [ ! $validator_name ]; then
        read -p "Введите ваше имя валидатора(придумайте, без спецсимволов - только буквы и цифры): " validator_name
    fi

    if [ ! $wallet ]; then
        read -p "Введите адрес кошелька ММ(начинается с 0x): " wallet
    fi

    if [ ! $private_key ]; then
        read -p "Введите приватник от ММ: " private_key
    fi
}

function install_docker {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
}

function prepare_docker_image {
    mkdir -p $HOME/elixir/
    cd $HOME/elixir/

    cat > $HOME/elixir/Dockerfile <<EOF
    FROM elixirprotocol/validator:testnet-2

    ENV ADDRESS=$wallet
    ENV PRIVATE_KEY=0x$private_key
    ENV VALIDATOR_NAME=$validator_name
EOF
}

function delete_old {
    docker rmi -f elixir-validator &>/dev/null
    docker rm -f ev &>/dev/null
    rm -rf $HOME/elixir/ &>/dev/null
}

function build_and_start {
    docker build . -f Dockerfile -t elixir-validator

    docker run -d --restart unless-stopped --name ev elixir-validator
}

function main {
    env
    install_docker
    delete_old
    prepare_docker_image
    build_and_start
}

main