#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

rustup target add riscv32i-unknown-none-elf
sudo apt install -y protobuf-compiler

# remove previous data
systemctl stop nexus &>/dev/null
systemctl disable nexus &>/dev/null
rm -rf $HOME/.nexus /etc/systemd/system/nexus.service 
source .profile

NEXUS_HOME="$HOME/.nexus"
mkdir -p "$NEXUS_HOME"

REPO_PATH="$NEXUS_HOME/network-api"
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating."
  (
    cd "$REPO_PATH" || exit
    git stash
    git fetch --tags
  )
else
  (
    cd "$NEXUS_HOME" || exit
    git clone https://github.com/nexus-xyz/network-api
  )
fi

(
  cd "$REPO_PATH" || exit
  git -c advice.detachedHead=false checkout "$(git rev-list --tags --max-count=1)"
)

cd "$REPO_PATH/clients/cli" 
cargo clean
RUST_BACKTRACE=1 cargo build --release

read -p "Введите node id: " Node_ID

echo $Node_ID > "$NEXUS_HOME"/node_id

cp /root/.nexus/network-api/clients/cli/target/release/nexus-network /root/.nexus/network-api/clients/cli/nexus-network

cat <<EOF | sudo tee /etc/systemd/system/nexus.service >/dev/null
[Unit]
Description=Nexus prover
After=network-online.target
StartLimitIntervalSec=0

[Service]
User=root
Restart=always
RestartSec=30
LimitNOFILE=65535
Type=simple
WorkingDirectory=/root/.nexus/network-api/clients/cli
ExecStart=/root/.nexus/network-api/clients/cli/nexus-network --start --env beta
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus
systemctl start nexus
lsb_release -a
rustc --version
cargo --version


echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"