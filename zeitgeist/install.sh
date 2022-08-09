#!/bin/bash
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
fi
echo 'Your node name: ' $NODENAME
sleep 1
echo 'export NODENAME='$NODENAME >> $HOME/.profile

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential git mc jq -y
curl https://getsubstrate.io -sSf | bash -s -- --fast
source $HOME/.cargo/env
sleep 1

git clone https://github.com/zeitgeistpm/zeitgeist.git
cd zeitgeist
git checkout v0.2.4
./scripts/init.sh
#cargo build --release
mkdir -p $HOME/zeitgeist/target/release/
wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.2.1/zeitgeist_parachain -O $HOME/zeitgeist/target/release/zeitgeist
chmod +x $HOME/zeitgeist/target/release/zeitgeist
curl -o $HOME/battery-station-relay.json https://raw.githubusercontent.com/zeitgeistpm/polkadot/battery-station-relay/node/service/res/battery-station-relay.json

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/zeitgeist.service
[Unit]
Description=Zeitgeist Node
After=network-online.target
[Service]
User=$USER
Nice=0
ExecStart=$HOME/zeitgeist/target/release/zeitgeist \
    --bootnodes=/ip4/45.33.117.205/tcp/30001/p2p/12D3KooWBMSGsvMa2A7A9PA2CptRFg9UFaWmNgcaXRxr1pE1jbe9 \
    --chain=battery_station \
    --name="$NODENAME | DOUBLETOP" \
    --parachain-id=2050 \
    --port=30333 \
    --rpc-port=9933 \
    --ws-port=9944 \
    --rpc-external \
    --ws-external \
    --rpc-cors=all \
    -- \
    --bootnodes=/ip4/45.33.117.205/tcp/31001/p2p/12D3KooWHgbvdWFwNQiUPbqncwPmGCHKE8gUQLbzbCzaVbkJ1crJ \
    --bootnodes=/ip4/45.33.117.205/tcp/31002/p2p/12D3KooWE5KxMrfJLWCpaJmAPLWDm9rS612VcZg2JP6AYgxrGuuE \
    --chain=$HOME/battery-station-relay.json \
    --port=30334 \
    --rpc-port=9934 \
    --ws-port=9945
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable zeitgeist
sudo systemctl restart zeitgeist

echo -e '\n\e[44mRun command to see logs: \e[0m\n'
echo 'journalctl -n 100 -f -u zeitgeist'

if [ ! -e $HOME/zeitgeist_bk/secret_ed25519 ]; then
  mkdir -p $HOME/zeitgeist_bk/
  cp $HOME/.local/share/zeitgeist/rococo/chains/rococo_battery_station_relay_testnet/network/secret_ed25519 $HOME/zeitgeist_bk/
fi
