#!/bin/bash

echo "-----------------------------------------------------------------------------"
echo "Обновление до версии 1.2.0"
echo "-----------------------------------------------------------------------------"

SERVER_IP=$(hostname -I | awk '{print $1}')
OG_PORT=12

sudo systemctl stop 0gchaind.service || true
sudo systemctl stop geth.service || true

echo "Скачиваем и распаковываем архив"
cd $HOME
source .profile
wget https://github.com/0glabs/0gchain-NG/releases/download/v1.2.0/galileo-v1.2.0.tar.gz
tar -xzf galileo-v1.2.0.tar.gz -C "$HOME" >/dev/null 2>&1
rm galileo-v1.2.0.tar.gz
sudo chmod +x $HOME/galileo-v1.2.0/bin/geth
sudo chmod +x $HOME/galileo-v1.2.0/bin/0gchaind

echo "Обновляем бинарники"
sudo cp $HOME/galileo-v1.2.0/bin/geth $HOME/go/bin/geth
sudo cp $HOME/galileo-v1.2.0/bin/0gchaind $HOME/go/bin/0gchaind

echo "Обновляем системный сервис 0gchaind"
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
    --p2p.external_address ${SERVER_IP}:${OG_PORT}656
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/galileo
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


echo "Перезапускаем сервисы"
sudo systemctl daemon-reload
sudo systemctl restart geth.service
sudo systemctl restart 0gchaind.service

echo "Текущая версия:"
0gchaind version

echo "RPC Node успешно обновлена"
echo "-----------------------------------------------------------------------------"