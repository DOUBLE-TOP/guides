#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
fi
echo 'Your node name: ' $NODENAME
sleep 1
echo 'export NODENAME='$NODENAME >> $HOME/.profile

sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential git mc jq wget -y
curl https://getsubstrate.io -sSf | bash -s -- --fast
source $HOME/.cargo/env
sleep 1

git clone https://github.com/bit-country/Bit-Country-Blockchain.git
cd Bit-Country-Blockchain
git checkout bfece87795f3b4bd4be225989af2ed717fbf9f8c
#./scripts/init.sh
mkdir -p $HOME/Bit-Country-Blockchain/target/release/
wget -O $HOME/Bit-Country-Blockchain/target/release/bitcountry-node http://65.21.227.180/bitcountry-node
chmod +x $HOME/Bit-Country-Blockchain/target/release/bitcountry-node
#rustup update nightly-2021-03-01
#rustup update stable

#rustup target add wasm32-unknown-unknown --toolchain nightly-2021-03-01
#rustup default nightly-2021-03-01
#cargo build --release --features=with-bitcountry-runtime

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/bitcountry.service
[Unit]
Description=bitcountry Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/Bit-Country-Blockchain/target/release/bitcountry-node --chain tewai --bootnodes /ip4/65.21.227.180/tcp/30333/p2p/12D3KooWKdVWge2uoUbhUZF4Rn4tCFKKCgiiRcPFXWFnx5ufwF1h --telemetry-url 'wss://telemetry.polkadot.io/submit/ 0' --validator --name "$NODENAME | DOUBLETOP"
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bitcountry
sudo systemctl restart bitcountry

echo -e '\n\e[44mRun command to see logs: \e[0m\n'
echo 'journalctl -n 100 -f -u bitcountry'
