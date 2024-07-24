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
echo -e "Введите имя ноды для телеметрии"
read SUBSPACE_NODENAME
fi

if [ ! $OPERATOR_ID ]; then
echo -e "Введите оператор ИД"
read OPERATOR_ID
fi

sudo tee <<EOF >/dev/null /etc/systemd/system/ssw_operator.service
[Unit]
  Description=Subspace Stake Wars Operator
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$HOME/subspace_stake_wars/subspace-node run --chain gemini-3h --name $SUBSPACE_NODENAME --base-path $HOME/subspace_stake_wars --blocks-pruning archive-canonical --state-pruning archive-canonical --domain-id 0 --operator-id $OPERATOR_ID --listen-on /ip4/0.0.0.0/tcp/40333
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=65535
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable ssw_operator
sudo systemctl daemon-reload
sudo systemctl start ssw_operator

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"