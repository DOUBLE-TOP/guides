#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $MASA_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " MASA_NODENAME
    echo 'export MASA_NODENAME='$MASA_NODENAME >> $HOME/.profile
fi
sleep 1
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null
sudo apt install nano mc wget -y &>/dev/null
source $HOME/.profile
sleep 1
cd $HOME
sudo apt install apt-transport-https -y &>/dev/null
# curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg
# curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-focal.list >/etc/apt/sources.list.d/openvpn3.list
# sudo apt update &>/dev/null
# sudo apt install openvpn3 -y &>/dev/null
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
if [ ! -d $HOME/masa-node-v1.0/ ]; then
  git clone https://github.com/masa-finance/masa-node-v1.0 &>/dev/null
fi
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd $HOME/masa-node-v1.0/src
git checkout v1.04
make all &>/dev/null
go get github.com/ethereum/go-ethereum/accounts/keystore &>/dev/null
cd $HOME/masa-node-v1.0/src/build/bin
sudo cp * /usr/local/bin
echo "Ставим geth quorum"
echo "-----------------------------------------------------------------------------"
cd $HOME
wget https://artifacts.consensys.net/public/go-quorum/raw/versions/v21.10.0/geth_v21.10.0_linux_amd64.tar.gz &>/dev/null
tar -xvf geth_v21.10.0_linux_amd64.tar.gz &>/dev/null
rm -v geth_v21.10.0_linux_amd64.tar.gz &>/dev/null
chmod +x $HOME/geth
sudo mv -f $HOME/geth /usr/bin/
echo "Инициализируем ноду"
echo "-----------------------------------------------------------------------------"
cd $HOME/masa-node-v1.0
geth --datadir data init ./network/testnet/genesis.json
PRIVATE_CONFIG=ignore
echo 'export PRIVATE_CONFIG='${PRIVATE_CONFIG} >> $HOME/.profile
source $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Создаем сервис и добавляем в автозагрузку"
echo "-----------------------------------------------------------------------------"
sudo tee /etc/systemd/system/masad.service > /dev/null <<EOF
[Unit]
Description=MASA
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=/usr/bin/geth --identity ${MASA_NODENAME} --datadir $HOME/masa-node-v1.0/data --bootnodes enode://0f32e834eab8de99da713c657aa20607417357d85127258edc483584c935d442f148a8bcf27ff7eb079da6cb83125552c11f77b2c6bf5c24a0cc376f99bcf5ac@65.108.158.14:30300  --emitcheckpoints --istanbul.blockperiod 1 --mine --minerthreads 1 --syncmode full --verbosity 5 --networkid 190250 --rpc --rpccorsdomain "*" --rpcvhosts "*" --rpcaddr 127.0.0.1 --rpcport 8545 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --port 30300
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable masad
sudo systemctl restart masad

# curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/masa/connect.sh > $HOME/connect.sh
# chmod +x $HOME/connect.sh
#
# curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/masa/masa-testnet-dev-client-community.ovpn > $HOME/masa-testnet-dev-client-community.ovpn
#
# sudo tee <<EOF >/dev/null $HOME/cron_connect
# @reboot $HOME/connect.sh >> $HOME/cron_connect.log
# EOF
#
# crontab $HOME/cron_connect
#
# $HOME/connect.sh

echo "-----------------------------------------------------------------------------"
echo "Готово, нода установлена"
echo "-----------------------------------------------------------------------------"
