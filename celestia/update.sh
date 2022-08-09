#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
cd $HOME
source .profile
sleep 1
ver="1.17.2"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" &>/dev/null
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" &>/dev/null
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile &>/dev/null
source $HOME/.bash_profile
echo "Софт успешно обновлен, начинаем обновление репрозитория"
echo "-----------------------------------------------------------------------------"
sudo systemctl stop celestia-full celestia-light  &>/dev/null
cd $HOME
rm -rf celestia-node &>/dev/null
git clone https://github.com/celestiaorg/celestia-node.git &>/dev/null
echo "Репозиторий успешно обновлен, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd celestia-node
git checkout v0.2.0 &>/dev/null
make install &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"
echo "Чиним бридж"
echo "-----------------------------------------------------------------------------"
source $HOME/.profile

TRUSTED_SERVER="localhost:26657"
TRUSTED_HASH=$(curl -s $TRUSTED_SERVER/status | jq -r .result.sync_info.latest_block_hash)

rm -rf $HOME/.celestia-full $HOME/.celestia-bridge
if [ ! -d $HOME/.celestia-bridge ]; then
  celestia bridge init --core.remote tcp://127.0.0.1:26657 --headers.trusted-hash $TRUSTED_HASH  &>/dev/null
  sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-bridge/config.toml
fi

sudo tee /etc/systemd/system/celestia-bridge.service > /dev/null <<EOF
[Unit]
  Description=celestia-bridge
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which celestia) bridge start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-bridge &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart celestia-bridge

sleep 10

echo "Чиним лайт"
echo "-----------------------------------------------------------------------------"
TRUSTED_SERVER="localhost:26657"
TRUSTED_HASH=$(curl -s $TRUSTED_SERVER/status | jq -r .result.sync_info.latest_block_hash)
journalctl -u celestia-bridge -o cat -n 10000 --no-pager | grep -m 1 "*  /ip4/" > $HOME/multiaddress.txt
FULL_NODE_IP=$(cat $HOME/multiaddress.txt | sed -r 's/^.{3}//')
rm -rf $HOME/.celestia-light/
celestia light init --headers.trusted-peers $FULL_NODE_IP --headers.trusted-hash $TRUSTED_HASH &>/dev/null
sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-light/config.toml
sed -i.bak -e 's/Bootstrapper = false/Bootstrapper = true/g' $HOME/.celestia-light/config.toml
sed -i.bak -e 's/ListenAddresses = .*/ListenAddresses = ["\/ip4\/0.0.0.0\/tcp\/2122", "\/ip6\/::\/tcp\/2122"]/g' $HOME/.celestia-light/config.toml
sed -i.bak -e 's/NoAnnounceAddresses = .*/NoAnnounceAddresses = ["\/ip4\/0.0.0.0\/tcp\/2122", "\/ip4\/127.0.0.1\/tcp\/2122", "\/ip6\/::\/tcp\/2122"]/g' $HOME/.celestia-light/config.toml
sed -i.bak -e 's/BootstrapPeers = .*/BootstrapPeers = []/g' $HOME/.celestia-light/config.toml
sed -i.bak -e 's/MutualPeers = .*/MutualPeers = []/g' $HOME/.celestia-light/config.toml

sudo systemctl restart celestia-appd celestia-light

echo "-----------------------------------------------------------------------------"

echo "Нода обновлена и запущена"
echo "-----------------------------------------------------------------------------"
