#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $EVMOS_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " EVMOS_NODENAME
fi
sleep 1
echo 'export EVMOS_NODENAME='$EVMOS_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
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

if [ ! -d $HOME/evmos/ ]; then
  git clone https://github.com/tharsis/evmos.git &>/dev/null
	cd $HOME/evmos
	git checkout v0.3.0 &>/dev/null
fi
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd $HOME/evmos
make install &>/dev/null
echo "Билд закончен"
echo "-----------------------------------------------------------------------------"
evmosd config chain-id evmos_9000-2 &>/dev/null
evmosd config keyring-backend file &>/dev/null
evmosd init "$EVMOS_NODENAME" --chain-id evmos_9000-2 &>/dev/null
curl -s https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/genesis.json > ~/.evmosd/config/genesis.json
curl -s https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/peers.txt > peers.txt
evmosd unsafe-reset-all
PEERS=`awk '{print $1}' peers.txt | paste -s -d, -`
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.evmosd/config/config.toml
grep -qxF 'evm-timeout = "5s"' $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a evm-timeout = \"5s\"" $HOME/.evmosd/config/app.toml
grep -qxF "txfee-cap = 1" $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a txfee-cap = 1" $HOME/.evmosd/config/app.toml
grep -qxF "filter-cap = 200" $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a filter-cap = 200" $HOME/.evmosd/config/app.toml
grep -qxF "feehistory-cap = 100" $HOME/.evmosd/config/app.toml || sed -i "/\[json-rpc\]/a feehistory-cap = 100" $HOME/.evmosd/config/app.toml

# bootstrap_node="http://5.189.156.65:26657"; \
# latest_height=`wget -qO- "${bootstrap_node}/block" | jq -r ".result.block.header.height"`; \
# block_height=$((latest_height - 2000)); \
# trust_hash=`wget -qO- "${bootstrap_node}/block?height=${block_height}" | jq -r ".result.block_id.hash"`; \
# sed -i -e "s%^moniker *=.*%moniker = \"$EVMOS_NODENAME\"%; "\
# "s%^seeds *=.*%seeds = \"`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/2267211602bb6e004a10a7b6e0395eed7a74b689/olympus_mons/seeds.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
# "s%^persistent_peers *=.*%persistent_peers = \"847e72f31e1f87e8059231b4b9e3302989c22d3a@5.189.156.65:26656,`wget -qO - https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/evmos/peers.txt | tr '\n' ',' | sed 's%,$%%'`,`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/2267211602bb6e004a10a7b6e0395eed7a74b689/olympus_mons/peers.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
# "s%^enable *=.*%enable = false%; "\
# "s%^rpc_servers *=.*%rpc_servers = \"${bootstrap_node},${bootstrap_node}\"%; "\
# "s%^trust_height *=.*%trust_height = $block_height%; "\
# "s%^trust_hash *=.*%trust_hash = \"$trust_hash\"%" $HOME/.evmosd/config/config.toml
echo "Конфигурирование ноды закончено"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

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
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable evmos &>/dev/null
sudo systemctl start evmos
echo "Сервисные файлы созданы успешно, возвращаемся к гайду"
echo "-----------------------------------------------------------------------------"
