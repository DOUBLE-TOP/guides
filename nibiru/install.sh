#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $NIBIRU_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " NIBIRU_NODENAME
fi
sleep 1
NIBIRU_CHAIN="nibiru-itn-1"
echo 'export NIBIRU_CHAIN='$NIBIRU_CHAIN >> $HOME/.profile
echo 'export NIBIRU_NODENAME='$NIBIRU_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt upgrade -y
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget build-essential git jq make gcc tmux chrony lz4 unzip ncdu htop -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
cd $HOME
wget https://github.com/NibiruChain/nibiru/releases/download/v0.19.2/nibid_0.19.2_linux_amd64.tar.gz
tar -xvzf nibid_0.19.2_linux_amd64.tar.gz &>/dev/null
sudo chmod +x nibid
mkdir -p $HOME/go/bin
sudo mv nibid $HOME/go/bin/nibid
rm nibid_0.19.2_linux_amd64.tar.gz
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
nibid config chain-id $NIBIRU_CHAIN_ID
nibid config keyring-backend file
nibid init $NIBIRU_NODENAME --chain-id $NIBIRU_CHAIN_ID &>/dev/null
nibid config node tcp://127.0.0.1:11657
wget -O $HOME/.nibid/config/genesis.json https://networks.itn.nibiru.fi/nibiru-itn-1/genesis
#wget -qO $HOME/.nibid/config/addrbook.json https://snapshot.yeksin.net/nibiru/addrbook.json &>/dev/null
sed -i -e "s%^moniker *=.*%moniker = \"$NIBIRU_NODENAME\"%; "\
"s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; " $HOME/.nibid/config/config.toml
SEEDS="a431d3d1b451629a21799963d9eb10d83e261d2c@seed-1.itn-1.nibiru.fi:26656,6a78a2a5f19c93661a493ecbe69afc72b5c54117@seed-2.itn-1.nibiru.fi:26656"
PEERS="e2b8b9f3106d669fe6f3b49e0eee0c5de818917e@213.239.217.52:32656,930b1eb3f0e57b97574ed44cb53b69fb65722786@144.76.30.36:15662,ad002a4592e7bcdfff31eedd8cee7763b39601e7@65.109.122.105:36656,4a81486786a7c744691dc500360efcdaf22f0840@15.235.46.50:26656,68874e60acc2b864959ab97e651ff767db47a2ea@65.108.140.220:26656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:39656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nibid/config/config.toml
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025unibi\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.nibid/config/config.toml

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:11658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:11657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:11060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:11656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":11660\"%" $HOME/.nibid/config/config.toml

sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:11317\"%; s%^address = \":8080\"%address = \":11080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:11090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:11091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:11545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:11546\"%" $HOME/.nibid/config/app.toml


echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/nibid.service
[Unit]
  Description=Nibiru Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which nibid) start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=65535
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable nibid &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart nibid

echo "Validator Node $NIBIRU_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
