#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/install_docker.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/update_subspace.sh"
migrate="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/migrate.sh"

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
        export SUBSPACE_NODENAME
        export WALLET_ADDRESS
        . <(wget -qO- $install)
        cd $HOME
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful! Check your status of node in https://telemetry.subspace.network/#list/0x92e91e657747c41eeabed5129ff51689d2e935b9f6abfbd5dfcb2e1d0d035095" 0 0
    fi
elif [ "$option" = "update" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $update)
        cd $HOME
        dialog --title "Update complete" --msgbox "The updating of $node was successful! Check your status of node in https://telemetry.subspace.network/#list/0x92e91e657747c41eeabed5129ff51689d2e935b9f6abfbd5dfcb2e1d0d035095" 0 0
    fi
elif [ "$option" = "migrate" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $migrate)
        cd $HOME
        dialog --title "Migrate complete" --msgbox "The updating of $node was successful! Check your status of node in https://telemetry.subspace.network/#list/0x92e91e657747c41eeabed5129ff51689d2e935b9f6abfbd5dfcb2e1d0d035095" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        sudo systemctl stop subspace
        sudo systemctl disable subspace
        rm -rf $HOME/.local/share/pulsar/farms
        rm -rf $HOME/.local/share/pulsar/node
        rm -rf $HOME/.config/pulsar/
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi