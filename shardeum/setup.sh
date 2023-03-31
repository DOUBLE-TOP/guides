#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/install.sh"
healthcheck="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/health.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        WARNING_AGREE=y
        RUNDASHBOARD=y
        DASHPASS=$(dialog --inputbox "Set the password to access the Dashboard(without spec symbols):" 0 0 "qwerty123" --stdout)
        while true; do
            DASHPORT=$(dialog --inputbox "Enter the port (1025-65536) to access the web based Dashboard:" 0 0 "38080" --stdout)
            # Проверка, что порт свободен
            if ! nc -z localhost "$DASHPORT"; then
                break
            else
                dialog --msgbox "Port $DASHPORT is already in use. Please choose another port." 0 0
            fi
        done
        while true; do
            SHMEXT=$(dialog --inputbox "This allows p2p communication between nodes. Enter the first port (1025-65536) for p2p communication:" 0 0 "29001" --stdout)
            # Проверка, что порт свободен
            if ! nc -z localhost "$SHMEXT"; then
                break
            else
                dialog --msgbox "Port $SHMEXT is already in use. Please choose another port." 0 0
            fi
        done
        while true; do
            SHMINT=$(dialog --inputbox "Enter the second port (1025-65536) for p2p communication:" 0 0 "30001" --stdout)
            # Проверка, что порт свободен
            if ! nc -z localhost "$SHMINT"; then
                break
            else
                dialog --msgbox "Port $SHMINT is already in use. Please choose another port." 0 0
            fi
        done
        NODEHOME=$(dialog --inputbox "What base directory should the node use:" 0 0 "$HOME/.shardeum" --stdout)
        . <(wget -qO- $install) &>/dev/null
        cd $HOME
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful! Stake your tokens in node: https://$(curl -s https://api.ipify.org):$DASHPORT/maintenance" 0 0
    fi
elif [ "$option" = "healthcheck" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
        tmux new-session -d -s shardeum_healthcheck '. <(wget -qO- $healthcheck)'
        cd $HOME
        dialog --title "Healthcheck enabled" --msgbox "Healthcheck enabled for $node was successful!" 0 0
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