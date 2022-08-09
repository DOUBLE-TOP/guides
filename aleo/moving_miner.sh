#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

sudo apt update
sudo apt install curl make clang pkg-config libssl-dev build-essential git mc jq unzip -y
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sleep 1

git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd snarkOS
cargo build --release --verbose
# $HOME/snarkOS/target/release/snarkos experimental new_account >> $HOME/account_aleo.txt
sleep 2
echo 'export MINER_ADDRESS='$(cat $HOME/account_aleo.txt | awk '/Address/ {print $2}') >> $HOME/.profile
source $HOME/.profile
sleep 1
echo -e '\n\e[42mYour address - \e[0m' && echo ${MINER_ADDRESS} && sleep 1

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/miner.service
[Unit]
Description=Aleo Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/snarkOS/target/release/snarkos --trial --miner $MINER_ADDRESS
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable miner
sudo systemctl restart miner

tee <<EOF >/dev/null $HOME/monitoring.sh
printf "Aleo.org TESTNET2 monitoring for:\tlocalhost:3032\n"
echo ""
echo "-----------------------------------------------"
printf "CONNECTED PEERS:\n";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getconnectedpeers", "params": [] }' -H 'content-type: application/json' http://localhost:3032/ | jq '.result[]';
echo ""
printf "LATEST BLOCK HEIGHT:\t";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "latestblockheight", "params": [] }' -H 'content-type: application/json' http://localhost:3032/ | jq '.result';
echo "-----------------------------------------------"
echo ""
printf "NODE STATE:\t";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getnodestate", "params": [] }' -H 'content-type: application/json' http://localhost:3032/ | jq '.result';
echo "-----------------------------------------------"
EOF

chmod +x $HOME/monitoring.sh

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aleo/auto_update.sh > $HOME/miner_update.sh

#thanks nodes.guru for this script :)

chmod +x $HOME/miner_update.sh

sudo tee <<EOF >/dev/null /etc/cron.d/miner_update
*/30 * * * * $HOME/miner_update.sh >> $HOME/miner_update.log
EOF

crontab /etc/cron.d/miner_update
