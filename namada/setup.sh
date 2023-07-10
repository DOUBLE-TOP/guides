#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/namada/install_testnet.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/namada/update_testnet.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to apply $option to  $node?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        NAMADA_NAME=$(dialog --inputbox "Set nodename for Namada(without spec symbols):" 0 0 "qwerty123" --stdout)
        . <(wget -qO- $install) &>/dev/null
        cd $HOME
        dialog --title "Installation complete" --msgbox "The installation of $node was successful!" 0 0
    fi
elif [ "$option" = "update" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
        . <(wget -qO- $update) &>/dev/null
        cd $HOME
        dialog --title "Healthcheck enabled" --msgbox "Update for $node was successful!" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        sudo systemctl stop namada && sudo systemctl disable namada
        rm -rf /etc/systemd/system/namadad* $HOME/tendermint $HOME/namada $HOME/.local/share/namada/public-testnet-10.3718993c3648/db/
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi
