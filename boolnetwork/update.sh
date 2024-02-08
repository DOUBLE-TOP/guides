#!/bin/bash

function colors {
    GREEN="\e[32m"
    RED="\e[39m"
    YELLOW="\e[33m"
    NORMAL="\e[0m"
}

function logo {
    curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
    echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function output {
    echo -e "${YELLOW}$1${NORMAL}"
}

function get_nodename {
    BOOL_NODENAME=$(docker inspect boolnetwork --format '{{.Config.Cmd}}' | grep -oP '(?<=--name )[^ ]*')
}


function stop_old_container {
    output "Stop old container...."
    docker stop boolnetwork
    docker rm boolnetwork
}

function pull_image {
    output "Pull new image...."
    docker pull boolnetwork/bnk-node:release
}

function start_new_container {
    docker run -d -v $HOME/.boolnetwork:/bool/.local/share/bnk-node --restart unless-stopped --name boolnetwork boolnetwork/bnk-node:v0.10.0 --validator --chain=tee --name $BOOL_NODENAME --telemetry-url "wss://telemetry.doubletop.io/submit 0"
}

function main {
    colors
    logo
    line
    get_nodename
    stop_old_container
    pull_image
    start_new_container
    line
    output "Done!"
}