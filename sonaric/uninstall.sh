#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Удаление Sonaric Node"
echo "-----------------------------------------------------------------------------"

DEVNULL="/dev/null"

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

print_message() {
  tput bold
  echo ""
	echo "$@"
	echo ""
  tput sgr0
}

confirm_Y() {
  read -p "$1 [Y/n] " reply;
  if [ "$reply" = "${reply#[Nn]}" ]; then
    return 0
  fi
 return 1
}

# stop and delete all workloads
if ! command_exists sonaric; then
    echo "Sonaric installation is not found"
    exit 0
fi

confirm_Y "Вы дейтвительно хотите удалить Sonaric?" || exit 0

# check if systemctl unit is present and if it is active
if command_exists systemctl && systemctl list-units --full --all sonaricd.service | grep -Fq 'loaded'; then
    systemctl start sonaricd 
fi

# stop and delete all workloads
if command_exists sonaric; then
    systemctl start sonaricd
    print_message "Подготовка к удалению Sonaric..."
    confirm_Y "Хотите ли вы сделать бекап перед удалением?" && sonaric identity-export -o $HOME/.sonaric/identity.file
    sonaric stop
    sonaric delete -a --force
fi

print_message "Удаление установленных пакетов"

DEBIAN_FRONTEND=noninteractive apt-get remove --auto-remove -y -qq sonaricd
rm -f /etc/apt/sources.list.d/sonaric.list
rm -f /etc/apt/keyrings/sonaric.gpg

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"