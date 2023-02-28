#!/bin/bash

install="https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh"
healthcheck="https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/shardeum/health.sh"

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
            . <(wget -qO- https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
            . <(wget -qO- https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
            tmux new-session -d -s shardeum_healthcheck '. <(wget -qO- $healthcheck)'
            break
            ;;
        "${options[3]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done