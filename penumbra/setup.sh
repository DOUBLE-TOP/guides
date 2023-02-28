#!/bin/bash

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/penumbra/install_penumbra.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/penumbra/update_penumbra.sh"

if [ "$language" = "ukr" ]; then
	PS3='Виберіть опцію: '
	options=("Встановити ноду" "Оновити ноду" "Вийти з меню")
	selected="Ви вибрали опцію"
else
    PS3='Enter your option: '
    options=("Install node" "Update node" "Quit")
    selected="You choose the option"
fi

select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            echo "$selected $opt"
            sleep 1
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