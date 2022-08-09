#!/bin/bash
sudo systemctl stop evmos
evmosd unsafe-reset-all
#curl -s https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/genesis.json > ~/.evmosd/config/genesis.json
curl -s https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/peers.txt > peers.txt
PEERS=`awk '{print $1}' peers.txt | paste -s -d, -`
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.evmosd/config/config.toml
sudo systemctl restart evmos
