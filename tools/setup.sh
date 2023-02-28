#!/bin/bash

main="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh"
monitoring="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/monitoring/monitor.sh"
docker="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh"
rust="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh"
go="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh"
nodejs="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh"
proxy="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/3proxy.sh"

if [ "$language" = "ukr" ]; then
	PS3='Виберіть опцію: '
	options=("Встановити основні програми" "Встановити моніторинг" "Встановити Docker" "Встановити Rust" "Встановити GO" "Встановити NodeJS" "Встановити проксі для використання в антидетекті" "Вийти з меню")
	selected="Ви вибрали опцію"
else
    PS3='Enter your option: '
    options=("Install main tools" "Install monitoring" "Install Docker" "Install Rust" "Install GO" "Install NodeJS" "Install 3Proxy" "Quit")
    selected="You choose the option"
fi

select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $main)
            break
            ;;
        "${options[1]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $monitoring)
            break
            ;;
        "${options[2]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $docker)
            break
            ;;    
        "${options[3]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $rust)
            break
            ;;    
        "${options[4]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $go)
            break
            ;;    
        "${options[5]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $nodejs)
            break
            ;;    
        "${options[6]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $proxy)
            break
            ;;    
        "${options[7]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done