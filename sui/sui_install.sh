#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt install curl -y &>/dev/null
sudo apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC sudo apt-get install -y --no-install-recommends tzdata git ca-certificates libclang-dev cmake &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
source $HOME/.cargo/env
source $HOME/.profile
source $HOME/.bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
rm -rf /var/sui/db /var/sui/genesis.blob $HOME/sui $HOME/.sui
mkdir -p $HOME/.sui
git clone https://github.com/MystenLabs/sui.git
cd $HOME/sui
git checkout -B devnet --track upstream/devnet
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
# cargo build --release
if [ ! -d /etc/systemd/system/minima_9001.service ]; then
  no minima no conflicts
else
  sed -i -e "s/port 9001/port 19001/" /etc/systemd/system/minima_9001.service
  sudo systemctl daemon-reload
  sudo systemctl restart minima_9001
fi
mkdir -p /root/sui/target/release/
version=0.12.2
wget -O $HOME/sui/target/release/sui https://doubletop-bin.ams3.digitaloceanspaces.com/sui/$version/sui
wget -O $HOME/sui/target/release/sui-node https://doubletop-bin.ams3.digitaloceanspaces.com/sui/$version/sui-node
wget -O $HOME/sui/target/release/sui-faucet https://doubletop-bin.ams3.digitaloceanspaces.com/sui/$version/sui-faucet
sudo chmod +x $HOME/sui/target/release/{sui,sui-node,sui-faucet}
sudo mv $HOME/sui/target/release/{sui,sui-node,sui-faucet} /usr/bin/
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
cp $HOME/sui/crates/sui-config/data/fullnode-template.yaml $HOME/.sui/fullnode.yaml
sed -i -e "s%db-path:.*%db-path: \"$HOME/.sui/db\"%; "\
"s%metrics-address:.*%metrics-address: \"0.0.0.0:9184\"%; "\
"s%json-rpc-address:.*%json-rpc-address: \"0.0.0.0:9000\"%; "\
"s%genesis-file-location:.*%genesis-file-location: \"$HOME/.sui/genesis.blob\"%; " $HOME/.sui/fullnode.yaml
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/sui.service
[Unit]
  Description=SUI Node
  After=network-online.target
[Service]
  User=$USER
  ExecStart=/usr/bin/sui-node --config-path $HOME/.sui/fullnode.yaml
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=65535
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable sui &>/dev/null
sudo systemctl restart sui

echo "Fullnode sui успешно установлена"
echo "-----------------------------------------------------------------------------"
