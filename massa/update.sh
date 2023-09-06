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
	rm -rf $HOME/massa_backup/
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
  rm -rf massa_TEST.*
  rm -rf $HOME/massa
}

function version {
  version="26.0"
}

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST."$version"/massa_TEST."$version"_release_linux.tar.gz
  tar zxvf massa_TEST."$version"_release_linux.tar.gz -C $HOME/
}

function routable_ip {
  sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
  sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
}

function keys_from_backup {
	cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat
	cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
}

colors

version
get_env
massa_backup
delete

install
routable_ip
keys_from_backup

sudo systemctl start massa
