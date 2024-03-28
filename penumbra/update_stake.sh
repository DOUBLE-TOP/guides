#!/bin/bash

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function install_tools {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
  source ~/.cargo/env
  rustup default nightly
  sleep 1
}

function source_git {
  if [ ! -d $HOME/penumbra/ ]; then
    git clone https://github.com/penumbra-zone/penumbra
  fi
  cd $HOME/penumbra
  git reset --hard
  git fetch
  git checkout $version && cargo update
}

# function build_penumbra {
#   if [ ! -d $HOME/penumbra/ ]; then
#     cd $HOME/penumbra/
#     cargo build --release --bin pcli
#     sudo rm -f /usr/bin/pcli
#     sudo cp target/release/pcli /usr/bin/pcli
#   else
#     source_git
#     cd $HOME/penumbra/
#     cargo build --release --bin pcli
#     sudo rm -f /usr/bin/pcli
#     sudo cp target/release/pcli /usr/bin/pcli
#   fi
# }

function wget_bin_pcli {
  mkdir -p $HOME/penumbra/target/release/
  wget -O  $HOME/penumbra/target/release/pcli https://doubletop-bin.ams3.digitaloceanspaces.com/penumbra/$version/pcli
  sudo chmod +x $HOME/penumbra/target/release/pcli
  sudo cp $HOME/penumbra/target/release/pcli /usr/bin/pcli
}

function generate_wallet {
  cd $HOME/penumbra/
  pcli keys generate
}

function reset_wallet {
  cd $HOME/penumbra/
  pcli view reset
}

function stake {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/penumbra/autostake.sh | bash
}

function view {
  pcli view staked
}
# function rust_update {
#   source ~/.cargo/env
#   rustup update
#   rustup default nightly
# }


colors
export version="v0.71.0"
# source_git
# rust_update

# build_penumbra
wget_bin_pcli
reset_wallet
stake
view
