#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/Gear/intsall_gear.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/Gear/update_gear.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        NODENAME_GEAR=$(dialog --inputbox "Enter node name(without special symbols):" 0 0 "randomnoderunner" --stdout)
        . <(wget -qO- $install) &>/dev/null
        cd $HOME
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful! Check your status of node in https://telemetry.doubletop.io/" 0 0
    fi
elif [ "$option" = "update" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $update) &>/dev/null
        cd $HOME
        dialog --title "Update complete" --msgbox "The updating of $node was successful! Check your status of node in https://telemetry.doubletop.io/" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        sudo systemctl stop gear
        sudo systemctl disable gear
        rm -rf $HOME/.local/share/gear/chains/*/db
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi