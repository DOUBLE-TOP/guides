#!/bin/bash
sudo systemctl stop assetnode
assetNode unsafe-reset-all
persistent_peers=`wget -qO - https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/assetNode/peers.txt | tr '\n' ',' | sed 's%,$%%'`
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$persistent_peers\"/" $HOME/.assetNode/config/config.toml
sudo systemctl start assetnode
