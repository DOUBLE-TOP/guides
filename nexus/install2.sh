#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash

# remove previous data
systemctl stop nexus
systemctl disable nexus
mkdir -p $HOME/nexus_backups/testnet0
cp $HOME/.nexus/prover-id $HOME/nexus_backups/testnet0/prover-id
rm -rf $HOME/.nexus
sudo rm -rf /etc/systemd/system/nexus.service 

sudo apt install -y protobuf-compiler

source .profile

NEXUS_HOME=$HOME/.nexus

mkdir -p $NEXUS_HOME

REPO_PATH=$NEXUS_HOME/network-api
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating.";
  (cd $REPO_PATH && git stash save && git fetch --tags)
else
  mkdir -p $NEXUS_HOME
  (cd $NEXUS_HOME && git clone https://github.com/nexus-xyz/network-api)
fi
(cd $REPO_PATH && git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1))

cd $REPO_PATH/clients/cli
cargo clean
cargo run --release -- --start --beta

cp /root/.nexus/network-api/clients/cli/target/release/prover /root/.nexus/network-api/clients/cli/prover

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
ExecStart=/root/.nexus/network-api/clients/cli/prover
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