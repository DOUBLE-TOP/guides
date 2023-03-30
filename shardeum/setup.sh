#!/bin/bash

node=$1
option=$2

install="https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh"
healthcheck="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/health.sh"

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $install)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "healthcheck" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
        tmux new-session -d -s shardeum_healthcheck '. <(wget -qO- $healthcheck)'
        dialog --title "Healthcheck enabled" --msgbox "Healthcheck enabled for $node was successful!" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        cd $HOME/.shardeum && ./cleanup.sh
        cd $HOME && rm -rf $HOME/.shardeum/
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi