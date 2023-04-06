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
text="The installation was successful!"
if [ "$?" -eq 0 ]; then
    confirm=1
else
    confirm=0
fi
if [[ $# -eq 3 ]]; then
  if [ "$3" == "--force" ]; then
    force="true"
  fi
fi

dialog_text() {
    if [ -z "$force" ] || [ "$force" != "true" ]; then
        dialog --title "Installation complete" --msgbox "$text" 0 0
    fi
}

# Show the main menu
if [ "$option" = "main" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $main) &>/dev/null
        dialog_text
    fi
elif [ "$option" = "monitoring" ]; then
    if [ "$confirm" != "0" ]; then
        if [ ! $OWNER ]; then
            OWNER=$(dialog --inputbox "Enter telegram username without @:" 0 0 "John" --stdout)
        fi
        if [ ! $NODENAME ]; then
            NODENAME=$(dialog --inputbox "Enter server name without special symbols:" 0 0 "server" --stdout)
        fi
        . <(wget -qO- $monitoring) &>/dev/null
        text="Monitoring installed! Your link in Grafana is:\nhttps://grafana.razumv.tech/d/xfpJB9FGz123/nodes-doubletop?var-owner=$OWNER&var-node=$NODENAME"
        dialog_text
        unset OWNER NODENAME
    fi
elif [ "$option" = "docker" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $docker) &>/dev/null
        dialog_text
    fi
elif [ "$option" = "rust" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $rust) &>/dev/null
        dialog_text
    fi
elif [ "$option" = "go" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $go) &>/dev/null
        dialog_text
    fi
elif [ "$option" = "nodejs" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $nodejs) &>/dev/null
        dialog_text
    fi
elif [ "$option" = "proxy" ]; then
    if [ "$confirm" != "0" ]; then
        . <(wget -qO- $proxy) &>/dev/null
        dialog_text
    fi
else
    dialog --title "Installation cancelled" --msgbox "The installation was cancelled." 0 0
fi