#!/bin/bash
if [ ! -e $HOME/account_aleo.txt ]; then
  cp $HOME/aleo/account.txt $HOME/account_aleo.txt
fi
#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash

sudo apt install wget -y
rustup update
sudo systemctl stop miner
rm -rf $HOME/snarkOS
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd $HOME/snarkOS
cargo build --release --verbose

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

echo 'export MINER_ADDRESS='$(cat $HOME/account_aleo.txt | awk '/Address/ {print $2}') >> $HOME/.profile
source $HOME/.profile
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

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aleo/auto_update.sh > $HOME/miner_update.sh
#thanks nodes.guru for this script :)

chmod +x $HOME/miner_update.sh

sudo tee <<EOF >/dev/null /etc/cron.d/miner_update
*/30 * * * * $HOME/miner_update.sh >> $HOME/miner_update.log
EOF

crontab /etc/cron.d/miner_update

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
