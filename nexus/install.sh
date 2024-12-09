#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null

source .profile

NEXUS_HOME=$HOME/.nexus

mkdir -p $NEXUS_HOME

PROVER_ID=$(cat $NEXUS_HOME/prover-id 2>/dev/null)
if [ -z "$NONINTERACTIVE" ] && [ "${#PROVER_ID}" -ne "28" ]; then
    read -p "Prover Id " PROVER_ID </dev/tty
    while [ ! ${#PROVER_ID} -eq "0" ]; do
        if [ ${#PROVER_ID} -eq "28" ]; then
            if [ -f "$NEXUS_HOME/prover-id" ]; then
                echo Copying $NEXUS_HOME/prover-id to $NEXUS_HOME/prover-id.bak
                cp $NEXUS_HOME/prover-id $NEXUS_HOME/prover-id.bak
            fi
            echo "$PROVER_ID" > $NEXUS_HOME/prover-id
            echo Prover id saved to $NEXUS_HOME/prover-id.
            break;
        else
            echo Unable to validate $PROVER_ID. Please make sure the full prover id is copied.
        fi
        read -p "Prover Id " PROVER_ID </dev/tty
    done
fi

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
cargo build --release --bin prover

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
ExecStart=/root/.nexus/network-api/clients/cli/prover -- beta.orchestrator.nexus.xyz
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"