#!/bin/bash

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/Gear/intsall_gear.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/Gear/update_gear.sh"

if [ "$language" = "ukr" ]; then
	PS3='Виберіть опцію: '
	options=("Встановити ноду" "Оновити ноду" "Вийти з меню")
	selected="Ви вибрали опцію"
	preinstall_message="Введіть ім'я ноди"
else
    PS3='Enter your option: '
    options=("Install node" "Update node" "Quit")
    selected="You choose the option"
    preinstall_message="Enter node name"
fi

select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            echo "$selected $opt"
            sleep 1
            if [ -z $NODENAME_GEAR ]; then
        		read -p "$preinstall_message: " NODENAME_GEAR
        		echo 'export NODENAME='$NODENAME_GEAR >> $HOME/.profile
			fi
            . <(wget -qO- $install)
            break
            ;;
        "${options[1]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $update)
            break
            ;;
        "${options[2]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done