#!/bin/bash

function logo {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh)
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function main_tools {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
  sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
  sudo apt install -y uidmap dbus-user-session
}

function rust {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh)
  source $HOME/.profile
}

function nodejs {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh)
}

function go {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)
}

function NAMADA_NAME {
  source $HOME/.bash_profile
  if [ ! ${NAMADA_NAME} ]; then
  echo "Введите свое имя ноды(придумайте)"
  line
  read NAMADA_NAME
  fi
}

function vars {
  echo "export NAMADA_TAG=v0.17.5" >> ~/.bash_profile
  echo "export CHAIN_ID=public-testnet-10.3718993c3648" >> ~/.bash_profile
  echo "export VALIDATOR_ALIAS=$NAMADA_NAME" >> ~/.bash_profile
  echo "export WALLET=$NAMADA_NAME" >> ~/.bash_profile
  source ~/.bash_profile
}

# function build_namada {
#   cd $HOME
#   git clone https://github.com/anoma/namada
#   cd namada
#   git checkout $NAMADA_TAG
#   make build-release
#
# }
#
# function build_tendermint {
#     cd $HOME
#     git clone https://github.com/heliaxdev/tendermint
#     cd tendermint
#     make build
# }
#
# function copy_bin {
#   sudo cp "$HOME/tendermint/build/tendermint" /usr/local/bin/tendermint
#   sudo cp $HOME/namada/target/release/{namada,namadac,namadan,namadaw} /usr/local/bin/
# }

function wget_bin {
  sudo wget -O /usr/local/bin/namada https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namada
  sudo wget -O /usr/local/bin/namadac https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadac
  sudo wget -O /usr/local/bin/namadan https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadan
  sudo wget -O /usr/local/bin/namadaw https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadaw
  sudo wget -O /usr/local/bin/tendermint https://doubletop-bin.ams3.digitaloceanspaces.com/namada/tendermint
  sudo wget -O /usr/local/bin/cometbft https://doubletop-bin.ams3.digitaloceanspaces.com/namada/cometbft
  sudo chmod +x /usr/local/bin/{tendermint,namada,namadac,namadan,namadaw,cometbft}
}

function join_network {
  cd $HOME
  namada client utils join-network --chain-id $CHAIN_ID
  mkdir -p $HOME/.local/share/namada/${CHAIN_ID}/tendermint/config/
  wget -O $HOME/.local/share/namada/${CHAIN_ID}/tendermint/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json
  sudo sed -i 's/0\.0\.0\.0:26656/0\.0\.0\.0:51656/g; s/127\.0\.0\.1:26657/127\.0\.0\.1:51657/g' $HOME/.local/share/namada/public-testnet*/config.toml
}

function systemd_namada {
  sudo tee /etc/systemd/system/namada.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target

[Service]
User=root
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run
StandardOutput=syslog
StandardError=syslog
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable namada
  sudo systemctl restart namada
}

colors
line
logo
line
NAMADA_NAME
line
echo "installing tools...."
line
main_tools
rust
nodejs
go
line
echo "set vars, build bin files"
vars
# build_namada
# build_tendermint
# copy_bin
wget_bin
line
echo "run fullnode"
join_network
systemd_namada
line
echo "fullnode started, next steps in the guide"
