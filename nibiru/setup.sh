#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/nibiru/install.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        NIBIRU_NODENAME=$(dialog --inputbox "Enter node name(without special symbols):" 0 0 "randomnoderunner" --stdout)
        . <(wget -qO- $install)
        cd $HOME
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        sudo systemctl stop nibid
        sudo systemctl disable nibid
        rm -rf $HOME/.nibid
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi