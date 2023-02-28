#!/bin/bash

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/clear_massa.sh"
update="curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/update.sh"
auto_buy_rolls="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/rolls.sh"

if [ "$language" = "ukr" ]; then
	PS3='Виберіть опцію: '
	options=("Встановити ноду" "Запустити хелс-чек для автоматичної перевірки статусу ноди" "Вийти з меню")
	selected="Ви вибрали опцію"
    preinstall_message="Введіть пароль для ноди(без спец символів)"
else
    PS3='Enter your option: '
    options=("Install node" "Start healthcheck" "Quit")
    selected="You choose the option"
    preinstall_message="Enter password for node(without special symbols)"
fi

select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            echo "$selected $opt"
            sleep 1
            if [ ! ${massa_pass} ]; then
                read -p "$preinstall_message: " massa_pass
                echo "export massa_pass=$massa_pass" >> $HOME/.profile
                source $HOME/.profile
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
            tmux new-session -d -s rolls '. <(wget -qO- $auto_buy_rolls)'
            break
            ;;
        "${options[3]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done