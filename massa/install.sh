#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

sudo apt update
#sudo apt install curl make clang pkg-config libssl-dev build-essential git mc jq unzip -y
#curl https://getsubstrate.io -sSf | bash -s -- --fast
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash

#
source $HOME/.cargo/env
sleep 1
rustup toolchain install nightly
rustup default nightly
cd $HOME
if [ ! -d $HOME/massa/ ]; then
	git clone https://github.com/massalabs/massa
	cd $HOME/massa && git checkout TEST.14.7
fi
cd $HOME/massa/massa-node/
cargo build --release
#sed -i 's%bootstrap_list *=.*%bootstrap_list = [ [ "62.171.166.224:31245", "8Cf1sQA9VYyUMcDpDRi2TBHQCuMEB7HgMHHdFcsa13m4g6Ee2h",], [ "149.202.86.103:31245", "5GcSNukkKePWpNSjx9STyoEZniJAN4U4EUzdsQyqhuP3WYf6nj",], [ "149.202.89.125:31245", "5wDwi2GYPniGLzpDfKjXJrmHV3p1rLRmm4bQ9TUWNVkpYmd4Zm",], [ "158.69.120.215:31245", "5QbsTjSoKzYc8uBbwPCap392CoMQfZ2jviyq492LZPpijctb9c",], [ "158.69.23.120:31245", "8139kbee951YJdwK99odM7e6V3eW7XShCfX5E2ovG3b9qxqqrq",],]%' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/ip *=.*/ip = \"127\.0\.0\.1\"/" "$HOME/massa/massa-client/base_config/config.toml"
sed -i "s/^bind_private *=.*/bind_private = \"127\.0\.0\.1\:33034\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/^bind_public *=.*/bind_public = \"0\.0\.0\.0\:33035\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"

# echo '[bootstrap]
# max_ping = 10000
#         bootstrap_list = [
#         ["185.217.126.178:31245", "7bKVu43o1e6MZsj9xsKFcq14B75vNjirTSW2umaaTMngfbWsL3"],
#         ["104.129.128.122:31245", "5EBePa834f8P3Ei6Vx7JFPzaq6JpsL4fDBRwePWfkiWM45yh6n"],
#         ["65.21.242.5:31245",  "6gkR8BbtpKCSkSoXtdmj1722Gp1iH49D2F8kJhGD6k1VhJrChH"],
#         ["51.250.18.248:31245",  "7tg9CfaM2xCiqyiZutpsagGrK5TtkU2paK7nLLoa21qdqjhZMR"],
#         ["135.181.112.215:31245", "6jeAcQYVTjiJnw4eyr8SMWAsAaMtWLN6HutNfVvB9TfV8EZEep"],
#         ["38.242.201.240:31245", "5yEwmraRY7wnEUZDzcWbnJ6sYqXaxcy8GfrDeJ6PTXx3HEKF92"],
#         ["194.163.166.47:31245",   "74a6newcBkijYx6YSaQcyHX5j5oSjF2wFEAahGb7XNxQZSfboF"],
#         ["194.163.182.239:31245", "6BDnKc5L7mpbW5K7c99TxZ5bQatpw2yiKPhTvPr49rNe9QnC7p"],
#         ["178.170.41.160:31245", "8mVVr2pyNgDqxBS9LCCmX8gBLAvc1R6wt5mwZgbZtj26oGmUWs"],
#         ["195.201.91.249:31245", "8UzkUgUTtdfntGsuUfbvmLZREnYYBU2mi6ggebcJsBsDTBX7z2"]
#     ]' > massa/massa-node/config/config.toml

sudo tee <<EOF >/dev/null /etc/systemd/system/massa.service
[Unit]
Description=Massa Node
After=network-online.target
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/target/release/massa-node
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald
sudo systemctl enable massa
sudo systemctl daemon-reload
sudo systemctl restart massa

cd $HOME/massa/massa-client/
# cargo run --release
# while [ ! -f $HOME/massa/massa-client/config/history.txt ]
# do
#   sleep 10
# done
# rm $HOME/massa/massa-client/config/history.txt
cargo run -- --wallet wallet.dat wallet_generate_private_key
# while [ ! -f $HOME/massa/massa-client/config/history.txt ]
# do
#   sleep 10
# done
# cd

echo "alias client='cd $HOME/massa/massa-client/ && cargo run --release && cd'" >> ~/.profile
echo "alias clientw='cd $HOME/massa/massa-client/; cargo run -- --wallet wallet.dat; cd'" >> ~/.profile

cd $HOME
mkdir -p $HOME/bk
cp $HOME/massa/massa-node/config/node_privkey.key $HOME/bk/
cp $HOME/massa/massa-client/wallet.dat $HOME/bk/
if [ ! -e $HOME/massa_bk.tar.gz ]; then
	tar cvzf massa_bk.tar.gz bk
fi

sudo systemctl restart massa
sleep 10
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/bootstrap-fix.sh | bash
