#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/taiko/install.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        ALCHEMY_KEY=$(dialog --inputbox "Enter your http url:" 0 0 "https://eth-sepolia.g.alchemy.com/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN" --stdout)
        ALCHEMY_WS=$(dialog --inputbox "Enter your wss url:" 0 0 "wss://eth-sepolia.g.alchemy.com/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN" --stdout)
        TAIKO_KEY=$(dialog --inputbox "Enter your private key from Metamask:" 0 0 "axxxcf5429bxxx9b66f9d973xxxxxxx151d93dff25550484c0efxxxxxadc" --stdout)
        . <(wget -qO- $install)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful! Check your status of node in Grafana: http://$(curl -s https://api.ipify.org):13000/d/L2ExecutionEngine/l2-execution-engine-overview?orgId=1&refresh=10s" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        cd $HOME/simple-taiko-node/ && docker-compose down -v
        cd $HOME && rm -rf simple-taiko-node/
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi