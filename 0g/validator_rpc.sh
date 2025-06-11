#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~2-5 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null

read -p "Введите моникер (имя): " NAME

SERVER_IP=$(hostname -I | awk '{print $1}')
OG_PORT=12

cd $HOME

# Remove galileo / .0gchaind dirs if any
echo "Удаляем Galileo и 0gchain если уже установлены"
sudo systemctl stop 0gd >/dev/null 2>&1 || true && sudo systemctl disable 0gd >/dev/null 2>&1 || true
sudo systemctl stop 0ggeth >/dev/null 2>&1 || true && sudo systemctl disable 0ggeth >/dev/null 2>&1 || true 
sudo systemctl stop geth >/dev/null 2>&1 || true && sudo systemctl disable geth >/dev/null 2>&1 || true 
sudo systemctl stop 0gchaind >/dev/null 2>&1 || true  && sudo systemctl disable 0gchaind >/dev/null 2>&1 || true 
rm -rf galileo >/dev/null 2>&1
rm -rf galileo-v1.1.1.tar.gz galileo-v1.2.0.tar.gz .0gchaind >/dev/null 2>&1
rm -rf $HOME/go/bin/* >/dev/null 2>&1
sudo rm /usr/local/bin/0gchaind >/dev/null 2>&1

echo "Скачиваем и устанавливаем Galileo"
wget -q https://github.com/0glabs/0gchain-NG/releases/download/v1.2.0/galileo-v1.2.0.tar.gz
tar -xzf galileo-v1.2.0.tar.gz -C "$HOME" >/dev/null 2>&1
mv "$HOME/galileo-v1.2.0" "$HOME/galileo"
rm galileo-v1.2.0.tar.gz

sudo chmod +x $HOME/galileo/bin/geth
sudo chmod +x $HOME/galileo/bin/0gchaind
mkdir -p $HOME/go/bin
cp $HOME/galileo/bin/geth $HOME/go/bin/geth
cp $HOME/galileo/bin/0gchaind $HOME/go/bin/0gchaind

echo "export MONIKER='$NAME'" >> "$HOME/.bash_profile"
echo "export PATH='$PATH:/root/go/bin'" >> "$HOME/.profile"
source $HOME/.bash_profile
source $HOME/.profile
geth version
0gchaind version

mkdir -p $HOME/.0gchaind
cp -r $HOME/galileo/0g-home $HOME/.0gchaind

echo "Инициализируем Geth"
geth init --datadir $HOME/.0gchaind/0g-home/geth-home $HOME/galileo/genesis.json

echo "Инициализируем 0gchaind"
0gchaind init "$NAME" --home $HOME/.0gchaind/tmp

# Copy node files to 0gchaind home
cp $HOME/.0gchaind/tmp/data/priv_validator_state.json $HOME/.0gchaind/0g-home/0gchaind-home/data/
cp $HOME/.0gchaind/tmp/config/node_key.json $HOME/.0gchaind/0g-home/0gchaind-home/config/
cp $HOME/.0gchaind/tmp/config/priv_validator_key.json $HOME/.0gchaind/0g-home/0gchaind-home/config/
rm -rf $HOME/.0gchaind/tmp

# some additional config
sed -i -e "s|^keyring-backend *=.*|keyring-backend = \"os\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/client.toml
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i "s|^moniker *=.*|moniker = \"${NAME}\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
# ports update
sed -i "s/HTTPPort = .*/HTTPPort = ${OG_PORT}545/" $HOME/galileo/geth-config.toml
sed -i "s/WSPort = .*/WSPort = ${OG_PORT}546/" $HOME/galileo/geth-config.toml
sed -i "s/AuthPort = .*/AuthPort = ${OG_PORT}551/" $HOME/galileo/geth-config.toml
sed -i "s|ListenAddr = .*|ListenAddr = \":${OG_PORT}303\"|" $HOME/galileo/geth-config.toml
sed -i "s|node = .*|node = \"tcp://localhost:${OG_PORT}657\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/client.toml
sed -i "s|laddr = \"tcp://0.0.0.0:26656\"|laddr = \"tcp://0.0.0.0:${OG_PORT}656\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i "s|laddr = \"tcp://127.0.0.1:26657\"|laddr = \"tcp://127.0.0.1:${OG_PORT}657\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i "s|^proxy_app = .*|proxy_app = \"tcp://127.0.0.1:${OG_PORT}658\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i "s|^pprof_laddr = .*|pprof_laddr = \"0.0.0.0:${OG_PORT}060\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i "s|prometheus_listen_addr = \".*\"|prometheus_listen_addr = \"0.0.0.0:${OG_PORT}660\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
sed -i "s|address = \".*:3500\"|address = \"127.0.0.1:${OG_PORT}500\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i "s|^rpc-dial-url *=.*|rpc-dial-url = \"http://localhost:${OG_PORT}551\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml

echo "Создаем системный сервис 0gchaind"
sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0G Chain Daemon
After=network-online.target

[Service]
User=root
ExecStart=$HOME/go/bin/0gchaind start \\
    --rpc.laddr tcp://0.0.0.0:${OG_PORT}657 \\
    --chaincfg.chain-spec devnet \\
    --chaincfg.kzg.trusted-setup-path=$HOME/galileo/kzg-trusted-setup.json \\
    --chaincfg.engine.jwt-secret-path=$HOME/galileo/jwt-secret.hex \\
    --chaincfg.kzg.implementation=crate-crypto/go-kzg-4844 \\
    --chaincfg.engine.rpc-dial-url=http://localhost:${OG_PORT}551 \\
    --chaincfg.block-store-service.enabled \\
    --chaincfg.node-api.enabled \\
    --chaincfg.node-api.logging \\
    --chaincfg.node-api.address 0.0.0.0:${OG_PORT}500 \\
    --pruning=nothing \\
    --home $HOME/.0gchaind/0g-home/0gchaind-home \\
    --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656 \\
    --p2p.external_address $SERVER_IP:${OG_PORT}656
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/galileo
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo "Создаем системный сервис geth"
sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=Go Ethereum Client
After=network-online.target
Wants=network-online.target

[Service]
User=root
ExecStart=$HOME/go/bin/geth \\
    --config $HOME/galileo/geth-config.toml \\
    --datadir $HOME/.0gchaind/0g-home/geth-home \\
    --networkid 16601
Restart=always
WorkingDirectory=$HOME/galileo
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start services
sudo systemctl daemon-reload
sudo systemctl enable geth.service
sudo systemctl start geth.service
sudo systemctl enable 0gchaind.service
sudo systemctl start 0gchaind.service
echo "Готово. Проверять логи командой journalctl -u 0gchaind -u geth -f"
