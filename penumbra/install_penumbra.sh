#!/bin/bash

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function install_tools {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
  # source ~/.cargo/env
  # rustup default nightly
  sleep 1
}

function source_git {
  if [ ! -d $HOME/penumbra/ ]; then
    git clone https://github.com/penumbra-zone/penumbra
  fi
  cd $HOME/penumbra
  git fetch
  git checkout $version && cargo update
}

# function build_penumbra {
#   if [ ! -d $HOME/penumbra/ ]; then
#     cd $HOME/penumbra/
#     cargo build --release --bin pcli
#     sudo cp target/release/pcli /usr/bin/pcli
#   else
#     source_git
#     cd $HOME/penumbra/
#     cargo build --release --bin pcli
#     sudo cp target/release/pcli /usr/bin/pcli
#   fi
# }

function wget_bin_pcli {
  wget https://github.com/penumbra-zone/penumbra/releases/download/$version/pcli-x86_64-unknown-linux-gnu.tar.xz
  tar xvf pcli-x86_64-unknown-linux-gnu.tar.xz
  sudo chmod +x pcli-x86_64-unknown-linux-gnu/pcli
  sudo cp pcli-x86_64-unknown-linux-gnu/pcli /usr/bin/pcli
  rm -rf pcli-x86_64-unknown-linux-gnu.tar.xz chmod +x pcli-x86_64-unknown-linux-gnu
}

function generate_wallet {
  cd $HOME/penumbra/
  mkdir -p $HOME/.local/share/penumbra-testnet-archive/
  pcli keys generate
}

colors
export version="v0.65.0"
install_tools
# source_git
# build_penumbra
wget_bin_pcli
# generate_wallet
