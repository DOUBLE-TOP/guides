#!/bin/bash

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/clear_massa.sh"
update="curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/update.sh"
auto_buy_rolls="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/rolls.sh"

if [ "$language" = "uk" ]; then
	PS3='Виберіть опцію: '
	options=("Встановити ноду" "Запустити хелс-чек для автоматичної перевірки статусу ноди" "Вийти з меню")
	selected="Ви вибрали опцію"
else
    PS3='Enter your option: '
    options=("Install node" "Start healthcheck" "Quit")
    selected="You choose the option"
fi

select opt in "${options[@]}"
do
    case $opt in
        "${options[1]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $install)
            break
            ;;
        "${options[2]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $update)
            break
            ;;
        "${options[3]}")
            echo "$selected $opt"
            tmux new-session -d -s rolls '. <(wget -qO- $auto_buy_rolls)'
            break
            ;;
        "${options[4]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done