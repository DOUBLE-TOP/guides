#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

ARCHWAY_CHAIN="torii-1"
echo 'export ARCHWAY_CHAIN='$ARCHWAY_CHAIN >> $HOME/.profile
source $HOME/.profile
source .bashrc
echo "Начинаем обновление"
echo "-----------------------------------------------------------------------------"
systemctl stop archwayd
rm -rf $HOME/.archway/config/genesis.json
archwayd unsafe-reset-all

archwayd config chain-id $ARCHWAY_CHAIN
archwayd config keyring-backend file
archwayd init $ARCHWAY_NODENAME --chain-id $ARCHWAY_CHAIN &>/dev/null

sed -i -e "s%^moniker *=.*%moniker = \"$ARCHWAY_NODENAME\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"dcc82542a94ab6407733802dd50c098da6f27f72@35.184.247.99:26656\"%; "\
"s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; " $HOME/.archway/config/config.toml
wget -qO $HOME/.archway/config/genesis.json https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/genesis.json
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
systemctl start archwayd
echo "Нода запущена"
echo "-----------------------------------------------------------------------------"
