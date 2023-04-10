#!/bin/bash

node=$1
option=$2

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/clear_massa.sh"
update="curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/update.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "install" ]; then
    if [ "$confirm" != "0" ]; then
        massa_pass=$(dialog --inputbox "Enter password for node(without special symbols):" 0 0 "qwerty12345" --stdout)
        . <(wget -qO- $install)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "update" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $update)
        dialog --title "Update complete" --msgbox "The updating of $node was successful!" 0 0
    fi
elif [ "$option" = "rolls" ]; then
    if [ "$confirm" != "0" ]; then
        tmux kill-session -t rolls
        tmux new-session -d -s rolls '. <(wget -qO- https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/rolls.sh)'
        dialog --title "Auto buy rolls enabled" --msgbox "Auto buy rolls enabled for $node !" 0 0
    fi
elif [ "$option" = "delete" ]; then
    if [ "$confirm" != "0" ]; then
        sudo systemctl stop massa
        rm -rf $HOME/massa
        dialog --title "delete" --msgbox "$node was successful deleted!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi
