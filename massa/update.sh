#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function get_env {
	source $HOME/.profile
	source $HOME/.cargo/env
}

function massa_backup {
	cd $HOME
	if [ ! -d $HOME/massa_backup/ ]; then
		mkdir -p $HOME/massa_backup
		cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/
		cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/
	fi
	if [ ! -e $HOME/massa_backup.tar.gz ]; then
		tar cvzf massa_backup.tar.gz massa_backup
	fi
}

function delete {
  sudo systemctl stop massa
  rm -rf $HOME/massa
}

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST.14.7/massa_TEST.14.7_release_linux.tar.gz
  tar zxvf massa_TEST.14.7_release_linux.tar.gz -C $HOME/
}

function routable_ip {
  sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
  sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
}

function replace_bootstraps {
  	config_path="$HOME/massa/massa-node/base_config/config.toml"
  	bootstrap_list=`wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/bootstrap_list.txt | shuf -n50 | awk '{ print "        "$0"," }'`
  	len=`wc -l < "$config_path"`
  	start=`grep -n bootstrap_list "$config_path" | cut -d: -f1`
  	end=`grep -n "\[optionnal\] port on which to listen" "$config_path" | cut -d: -f1`
  	end=$((end-1))
  	first_part=`sed "${start},${len}d" "$config_path"`
  	second_part="
      bootstrap_list = [
  ${bootstrap_list}
      ]
  "
  	third_part=`sed "1,${end}d" "$config_path"`
  	echo "${first_part}${second_part}${third_part}" > "$config_path"
  	sed -i -e "s%retry_delay *=.*%retry_delay = 10000%; " "$config_path"
}

function keys_from_backup {
	cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat
	cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
}

function alias {
  echo "alias client='cd $HOME/massa/massa-client/ && $HOME/massa/massa-client/massa-client --pwd $massa_pass && cd'" >> ~/.profile
  echo "alias clientw='cd $HOME/massa/massa-client/ && $HOME/massa/massa-client/massa-client --pwd $massa_pass && cd'" >> ~/.profile
}

colors
line
logo
line
echo "Читаем переменные, делаем бекап"
line
get_env
massa_backup
echo "Удаляем старые файлы"
delete
line
echo "Скачиваем новую версию и переписываем конфиг"
install
#routable_ip
#replace_bootstraps
alias
line
#echo "Восстанавливаемся из бекапа"
#keys_from_backup
#line
sudo systemctl start massa
echo "Обновление завершено"
