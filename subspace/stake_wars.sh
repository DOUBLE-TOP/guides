#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка оператора"
echo "-----------------------------------------------------------------------------"

mkdir -p $HOME/subspace_stake_wars && cd $HOME/subspace_stake_wars

wget https://github.com/subspace/subspace/releases/download/gemini-3h-2024-jul-05/subspace-node-ubuntu-x86_64-skylake-gemini-3h-2024-jul-05 -O subspace-node

chmod +x subspace-node

./subspace-node domain key create --base-path $HOME/subspace_stake_wars --domain-id 0

if [ ! $SUBSPACE_NODENAME ]; then
echo -e "Enter your node name(random name for telemetry)"
line_1
read SUBSPACE_NODENAME
fi

services:
    node:
        image: ghcr.io/subspace/node:gemini-3h-2024-jul-05
        volumes:
            - $HOME/subspace_stake_wars:/var/subspace:rw
        ports:
            - "0.0.0.0:30333:30333/tcp"
            - "0.0.0.0:30433:30433/tcp"
            - "0.0.0.0:40333:40333/tcp"
        restart: unless-stopped
        command: [
            "run",
            "--chain", "gemini-3h",
            "--base-path", "/var/subspace",
            "--listen-on", "0.0.0.0:30333",
            "--dsn-listen-on", "/ip4/0.0.0.0/tcp/30433",
            # Replace INSERT_YOUR_ID with your node ID (will be shown in telemetry)
            "--name", "$SUBSPACE_NODENAME",
            "--blocks-pruning", "archive-canonical",
            "--state-pruning". "archive-canonical"
            "--",
            "--domain-id", "0",
            # Replace INSERT_YOUR_OPERATOR_ID with your operator ID
            "--operator-id", "INSERT_YOUR_OPERATOR_ID",
            "--listen-on", "/ip4/0.0.0.0/tcp/40333"
        ]
        healthcheck:
        timeout: 5s
    # If node setup takes longer than expected, you want to increase interval and retries number.
        interval: 30s
        retries: 60
    volumes:
    node-data:
        