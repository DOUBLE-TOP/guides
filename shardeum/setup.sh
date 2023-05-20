#!/bin/bash

node=$1
option=$2

main="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh"
docker="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh"
install="https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh"
healthcheck="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/health.sh"
unstake="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/unstake.sh"
stake="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/stake.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $main) &>/dev/null
        . <(wget -qO- $docker) &>/dev/null
        . <(wget -qO- $install)
        source $HOME/.shardeum/.env
        cd $HOME
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful! Stake your tokens in node: https://$SERVERIP:$DASHPORT/maintenance" 0 0
    fi
elif [ "$option" = "healthcheck" ]; then
    if [ "$confirm" != "0" ]; then
        tmux new-session -d -s shardeum_healthcheck '. <(wget -qO- $healthcheck)'
        cd $HOME
        dialog --title "Healthcheck enabled" --msgbox "Healthcheck enabled for $node was successful!" 0 0
    fi
elif [ "$option" = "unstake" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $unstake)
        cd $HOME
        dialog --title "Force unstake completed" --msgbox "Force unstake for $node was successful!" 0 0
    fi
elif [ "$option" = "stake" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $stake)
        cd $HOME
        dialog --title "Stake completed" --msgbox "Stake for $node was successful!" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        cd $HOME/.shardeum && ./cleanup.sh &>/dev/null
        cd $HOME && rm -rf $HOME/.shardeum/
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi