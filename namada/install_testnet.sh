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

function delete_old_dirs {
  rm -rf $HOME/namada
  rm -rf $HOME/cometbft
  rm -rf $HOME/.masp-params
  rm -rf $HOME/.local/share/namada

}

function protoc {
  cd $HOME && rustup update
  PROTOC_ZIP=protoc-23.3-linux-x86_64.zip
  curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v23.3/$PROTOC_ZIP
  sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
  sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
  rm -f $PROTOC_ZIP
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
  sed -i '/public-testnet/d' "$HOME/.bash_profile"
  sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
  sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"
  sed -i '/CBFT/d' "$HOME/.bash_profile"
  echo "export NAMADA_TAG=v0.17.5" >> ~/.bash_profile
  echo "export CHAIN_ID=public-testnet-10.3718993c3648" >> ~/.bash_profile
  echo "export CBFT=v0.37.2" >> ~/.bash_profile
  echo "export VALIDATOR_ALIAS=$NAMADA_NAME" >> ~/.bash_profile
  echo "export WALLET=$NAMADA_NAME" >> ~/.bash_profile
  echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile
  source ~/.bash_profile
}

function cometbft {
  source $HOME/.profile
  cd $HOME
  git clone https://github.com/cometbft/cometbft.git
  cd cometbft
  git checkout $CBFT
  make build
  cp $HOME/cometbft/build/cometbft /usr/local/bin/cometbft
}

function wget_bin {
  sudo wget -O /usr/local/bin/namada https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namada
  sudo wget -O /usr/local/bin/namadac https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadac
  sudo wget -O /usr/local/bin/namadan https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadan
  sudo wget -O /usr/local/bin/namadaw https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadaw
  sudo wget -O /usr/local/bin/tendermint https://doubletop-bin.ams3.digitaloceanspaces.com/namada/tendermint
  sudo chmod +x /usr/local/bin/{tendermint,namada,namadac,namadan,namadaw}
}

function join_network {
  cd $HOME
  namada client utils join-network --chain-id $CHAIN_ID
  mkdir -p $HOME/.local/share/namada/${CHAIN_ID}/tendermint/config/
  get -O $HOME/.local/share/namada/${CHAIN_ID}/cometbft/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json
  sudo sed -i 's/0\.0\.0\.0:26656/0\.0\.0\.0:51656/g; s/127\.0\.0\.1:26657/127\.0\.0\.1:51657/g; s/127\.0\.0\.1:26658/127\.0\.0\.1:51658/g' $HOME/.local/share/namada/public-testnet*/config.toml
}

function systemd_namada {
  sudo tee /etc/systemd/system/namada.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
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
protoc
delete_old_dirs
line
echo "set vars, build bin files"
vars
cometbft
wget_bin
line
echo "run fullnode"
join_network
systemd_namada
line
echo "fullnode started, next steps in the guide"
