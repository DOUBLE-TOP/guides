#!/bin/bash

install="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/bundlr/install_bundlr.sh"
update="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/bundlr/update_bundler.sh"
healthcheck="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/bundlr/health.sh"

if [ "$language" = "uk" ]; then
	PS3='Виберіть опцію: '
	options=("Встановити ноду" "Оновити ноду" "Запустити хелс-чек для автоматичної перевірки статусу ноди" "Вийти з меню")
	selected="Ви вибрали опцію"
else
    PS3='Enter your option: '
    options=("Install node" "Update node" "Start healthcheck" "Quit")
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
            tmux new-session -d -s bundlr_healthcheck '. <(wget -qO- $healthcheck)'
            break
            ;;
        "${options[4]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done