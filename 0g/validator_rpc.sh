#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~2-5 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null

read -p "Введите имя: " NAME

SERVER_IP=$(hostname -I | awk '{print $1}')

cd $HOME

# Remove galileo / .0gchaind dirs if any
echo "Удаляем Galileo и 0gchain если уже установлены"
sudo systemctl stop 0gd >/dev/null 2>&1 || true && sudo systemctl disable 0gd >/dev/null 2>&1 || true
sudo systemctl stop 0ggeth >/dev/null 2>&1 || true && sudo systemctl disable 0ggeth >/dev/null 2>&1 || true 
sudo systemctl stop 0gchaind >/dev/null 2>&1 || true  && sudo systemctl disable 0gchaind >/dev/null 2>&1 || true 
rm -rf galileo galileo-v1.0.1.tar.gz galileo-v1.1.0.tar.gz galileo-v1.1.1.tar.gz .0gchaind >/dev/null 2>&1
rm -rf $HOME/go/bin/* >/dev/null 2>&1
rm -rf $HOME/.bash_profile >/dev/null 2>&1
sudo rm /usr/local/bin/0gchaind >/dev/null 2>&1

echo "Скачиваем и устанавливаем Galileo"
wget -q https://github.com/0glabs/0gchain-NG/releases/download/v1.1.1/galileo-v1.1.1.tar.gz
tar -xzf galileo-v1.1.1.tar.gz -C "$HOME" >/dev/null 2>&1
cd galileo

cp -r 0g-home/* $HOME/galileo/0g-home/

sudo chmod 777 ./bin/geth
sudo chmod 777 ./bin/0gchaind

echo "Инициализируем Geth"
./bin/geth init --datadir $HOME/galileo/0g-home/geth-home ./genesis.json

echo "Инициализируем 0gchaind"
./bin/0gchaind init "$NAME" --home $HOME/galileo/tmp

cp $HOME/galileo/tmp/data/priv_validator_state.json $HOME/galileo/0g-home/0gchaind-home/data/
cp $HOME/galileo/tmp/config/node_key.json $HOME/galileo/0g-home/0gchaind-home/config/
cp $HOME/galileo/tmp/config/priv_validator_key.json $HOME/galileo/0g-home/0gchaind-home/config/

echo 'export PATH=$PATH:$HOME/galileo/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "Создаем системный сервис 0gchaind"
sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0gchaind Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'cd ~/galileo && ./bin/0gchaind start \
    --rpc.laddr tcp://0.0.0.0:26657 \
    --chain-spec devnet \
    --kzg.trusted-setup-path=kzg-trusted-setup.json \
    --engine.jwt-secret-path=jwt-secret.hex \
    --kzg.implementation=crate-crypto/go-kzg-4844 \
    --block-store-service.enabled \
    --node-api.enabled \
    --node-api.logging \
    --node-api.address 0.0.0.0:3500 \
    --pruning=nothing \
    --home $HOME/galileo/0g-home/0gchaind-home \
    --p2p.external_address $SERVER_IP:26656 \
    --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656'
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

echo "Создаем системный сервис 0ggeth"
sudo tee /etc/systemd/system/0ggeth.service > /dev/null <<EOF
[Unit]
Description=0g Geth Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'cd ~/galileo && ./bin/geth --config geth-config.toml \
    --nat extip:$SERVER_IP \
    --bootnodes enode://de7b86d8ac452b1413983049c20eafa2ea0851a3219c2cc12649b971c1677bd83fe24c5331e078471e52a94d95e8cde84cb9d866574fec957124e57ac6056699@8.218.88.60:30303 \
    --datadir $HOME/galileo/0g-home/geth-home \
    --networkid 16601'
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start services
sudo systemctl daemon-reload
sudo systemctl enable 0ggeth.service
sudo systemctl start 0ggeth.service
sudo systemctl enable 0gchaind.service
sudo systemctl start 0gchaind.service
echo "Готово. Проверять логи командой journalctl -u 0gchaind -u 0ggeth -f"
