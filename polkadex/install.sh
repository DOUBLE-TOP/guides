#!/bin/bash
#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

if [ ! $POLKADEX_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте): " POLKADEX_NODENAME
fi
sleep 1
echo 'export POLKADEX_NODENAME='$POLKADEX_NODENAME >> $HOME/.profile

sudo apt install git mc jq htop net-tools -y

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash
source $HOME/.cargo/env
sleep 1

rustup toolchain add nightly-2021-05-11
rustup target add wasm32-unknown-unknown --toolchain nightly-2021-05-11
rustup target add x86_64-unknown-linux-gnu --toolchain nightly-2021-05-11

cd $HOME
curl -O -L https://github.com/Polkadex-Substrate/Polkadex/releases/download/v0.4.1-rc5/customSpecRaw.json
git clone https://github.com/Polkadex-Substrate/Polkadex.git
cd $HOME/Polkadex
git checkout v0.4.1-rc5
cargo build --release

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/polkadex.service
[Unit]
Description=Polkadex Testnet Validator Service
After=network-online.target
Wants=network-online.target

[Service]
User=$USER
#ExecStart=$HOME/Polkadex/target/release/polkadex-node --rpc-cors=all --chain=$HOME/customSpecRaw.json --bootnodes /ip4/13.235.92.50/tcp/30333/p2p/12D3KooWC7VKBTWDXXic5yRevk8WS8DrDHevvHYyXaUCswM18wKd --pruning=archive --validator --name '$POLKADEX_NODENAME | DOUBLETOP'
ExecStart=$HOME/Polkadex/target/release/polkadex-node --chain=$HOME/customSpecRaw.json --rpc-cors=all --bootnodes /ip4/13.235.190.203/tcp/30333/p2p/12D3KooWC7VKBTWDXXic5yRevk8WS8DrDHevvHYyXaUCswM18wKd --validator --name '$POLKADEX_NODENAME | DOUBLETOP'
Restart=always
RestartSec=3
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable polkadex
sudo systemctl restart polkadex
