#!/bin/bash
function install_rust {
  sudo apt-get update
  sudo apt-get install build-essential cmake clang pkg-config libssl-dev gcc-multilib protobuf-compiler -y
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh)
  source ~/.cargo/env
  sleep 1
}

function source_lightning {
  git clone -b testnet-alpha-0 https://github.com/fleek-network/lightning.git
  cd $HOME/lightning
  cargo clean
  cargo update
  cargo build
}

function symlink {
  sudo ln -sf "$HOME/lightning/target/debug/lightning-node" /usr/local/bin/lgtn
}

function generate_keys {
  lgtn keys generate
}

function config {
  sed -i 's/testnet = .*/testnet = true/' $HOME/.lightning/config.toml
}

function systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/lgtn.service
[Unit]
Description=Fleek Network Node lightning service

[Service]
User=$USER
Type=simple
MemoryHigh=32G
RestartSec=15s
Restart=always
ExecStart=lgtn -c $HOME/lightning/lightning.toml run
StandardOutput=append:/var/log/lightning/output.log
StandardError=append:/var/log/lightning/diagnostic.log

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable lgtn
sudo systemctl restart lgtn
}

function main {
  install_rust
  source_lightning
  symlink
  generate_keys
  config
  systemd
}

main