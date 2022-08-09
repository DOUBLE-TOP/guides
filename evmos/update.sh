#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
git clone https://github.com/cosmos/cosmos-sdk
cd cosmos-sdk
git checkout v0.44.3
make cosmovisor
cp cosmovisor/cosmovisor $GOPATH/bin/cosmovisor
cd $HOME

mkdir -p ~/.evmosd
mkdir -p ~/.evmosd/cosmovisor
mkdir -p ~/.evmosd/cosmovisor/genesis
mkdir -p ~/.evmosd/cosmovisor/genesis/bin
mkdir -p ~/.evmosd/cosmovisor/upgrades

echo "# Setup Cosmovisor" >> ~/.profile
echo "export DAEMON_NAME=evmosd" >> ~/.profile
echo "export DAEMON_HOME=$HOME/.evmosd" >> ~/.profile
echo 'export PATH="$DAEMON_HOME/cosmovisor/current/bin:$PATH"' >> ~/.profile
source ~/.profile

sudo systemctl stop evmos
rm -f $HOME/.evmosd/config/genesis.json
cd $HOME/evmos
git fetch --all && git checkout v0.3.0
make install

cp $GOPATH/bin/evmosd ~/.evmosd/cosmovisor/genesis/bin

evmosd config chain-id evmos_9000-2

curl -s https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/genesis.json > ~/.evmosd/config/genesis.json

evmosd unsafe-reset-all
grep -qxF 'evm-timeout = "5s"' $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a evm-timeout = \"5s\"" $HOME/.evmosd/config/app.toml
grep -qxF "txfee-cap = 1" $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a txfee-cap = 1" $HOME/.evmosd/config/app.toml
grep -qxF "filter-cap = 200" $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a filter-cap = 200" $HOME/.evmosd/config/app.toml
grep -qxF "feehistory-cap = 100" $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a feehistory-cap = 100" $HOME/.evmosd/config/app.toml

sudo tee /etc/systemd/system/evmos.service > /dev/null <<EOF
[Unit]
Description=Evmos Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_HOME=$HOME/.evmosd"
Environment="DAEMON_NAME=evmosd"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
WantedBy=multi-user.target
EOF
sudo -S systemctl daemon-reload
sudo -S systemctl enable evmos
sudo -S systemctl restart evmos
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/evmos/update_peers.sh | bash


echo "-----------------------------------------------------------------------------"
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
