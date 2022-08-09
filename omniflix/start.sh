#!/bin/bash
#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

rm -rf $HOME/.omniflixhub/config/genesis*
wget -O $HOME/.omniflixhub/config/genesis.json https://raw.githubusercontent.com/OmniFlix/testnets/main/flixnet-2/genesis.json

seeds="cdd6f704a2ecb6b9e53a9b753c894c95976e5cbe@45.72.100.121:26656,b0679b09bb72dfc29c332b5ea754cd578d106a49@45.72.100.122:26656"
peers="65e362590690cedcddf5c7f4fc1b67c9d7b04fb2@45.72.100.118:26656,368a9a2b5096de253aaae302ff15a0a77fe06416@45.72.100.119:26656,cf8a7600b3daf23e9a3ce67ebe50c4af44701aa8@45.72.100.123:26656,93433a8c325d5ed5d2484d7fd23cda3dac511392@45.72.100.124:26656"

sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.omniflixhub/config/config.toml
omniflixhubd unsafe-reset-all

sudo systemctl start omniflixhubd

echo DONE
