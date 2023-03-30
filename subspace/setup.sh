#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/install.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/update_subspace.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        SUBSPACE_NODENAME=$(dialog --inputbox "Enter node name(without special symbols):" 0 0 "randomnoderunner" --stdout)
        WALLET_ADDRESS=$(dialog --inputbox "Enter your polkadot.js extension address:" 0 0 "st9XHxxxFBxXCExxxxxxxxxyuZgTYjixxxxxxxCpcUq9j" --stdout)
        . <(wget -qO- $install)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "update" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $update)
        dialog --title "Update complete" --msgbox "The updating of $node was successful!" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        docker-compose -f $HOME/subspace_docker/docker-compose.yml down -v
        rm -rf $HOME/subspace*
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi