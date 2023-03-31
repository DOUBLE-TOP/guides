#!/bin/bash

node=$1
option=$2

main="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh"
monitoring="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/monitoring/monitor.sh"
docker="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh"
rust="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh"
go="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh"
nodejs="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh"
proxy="https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/3proxy.sh"

confirm=$(dialog --clear --stdout --yesno "Do you want to install $node with option $option?" 0 0)

if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi

# Show the main menu
if [ "$option" = "main" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $main)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "monitoring" ]; then
    if [ "$confirm" != "0" ]; then
        OWNER=$(dialog --inputbox "Enter telegram username without @:" 0 0 "John" --stdout)
        HOSTNAME=$(dialog --inputbox "Enter server name without special symbols:" 0 0 "server" --stdout)
        . <(wget -qO- $monitoring)
        dialog --title "Installation complete" --msgbox "Monitoring installed! Your link in Grafana is - https://grafana.razumv.tech/d/xfpJB9FGz123/nodes-doubletop?orgId=1&var-origin_prometheus=&var-job=node_exporter&var-owner=$OWNER&var-hostname=All&var-node=$HOSTNAME&var-device=All&var-interval=2m&var-maxmount=%2F&var-show_hostname=subq&var-total=3" 0 0
    fi
elif [ "$option" = "docker" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $docker)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "rust" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $rust)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "go" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $go)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "nodejs" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $nodejs)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
elif [ "$option" = "proxy" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $proxy)
        dialog --title "Installation complete" --msgbox "The installation of $node with option $option was successful!" 0 0
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi