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

wget -O docker-compose.yml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subspace/stake_docker_compose.yml
sed -i "s|SUBSPACE_NODENAME|$SUBSPACE_NODENAME|" $HOME/subspace_stake_wars/docker-compose.yml
        
docker compose up -d

