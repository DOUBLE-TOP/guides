#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

PROTOC_VERSION=$(protoc --version 2>/dev/null | awk '{print $2}')
if [[ "$PROTOC_VERSION" != "3.21.12" ]]; then
    echo "Устанавливаем protoc версии 3.21.12"
    wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip
    unzip protoc-21.12-linux-x86_64.zip -d $HOME/.local
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "protoc 3.21.12 уже установлен, пропускаем установку."
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

rustup target add riscv32i-unknown-none-elf
sudo apt install -y protobuf-compiler

# remove previous data
systemctl stop nexus &>/dev/null
systemctl disable nexus &>/dev/null
rm -rf $HOME/.nexus /etc/systemd/system/nexus.service 
source .profile

# swap file fix

SWAP_LOCATE=$(swapon --show | awk 'NR==2 {print $1}') && \
swapoff $SWAP_LOCATE && rm $SWAP_LOCATE && \

fallocate -l 6G /swapfile && \
chmod 600 /swapfile && \
mkswap /swapfile && \
swapon /swapfile && \
swapon --show && \
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab && \
sysctl vm.swappiness=10 && \
sysctl vm.vfs_cache_pressure=50 && \
echo "vm.swappiness=10" >> /etc/sysctl.conf && \
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf


NEXUS_HOME="$HOME/.nexus"
mkdir -p "$NEXUS_HOME"

REPO_PATH="$NEXUS_HOME/network-api"
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating."
  (
    cd "$REPO_PATH" || exit
    git stash
    git fetch --tags
  )
else
  (
    cd "$NEXUS_HOME" || exit
    git clone https://github.com/nexus-xyz/network-api
  )
fi

(
  cd "$REPO_PATH" || exit
  git -c advice.detachedHead=false checkout "$(git rev-list --tags --max-count=1)"
)

cd "$REPO_PATH/clients/cli" 
cargo clean
RUST_BACKTRACE=1 cargo build --release

cp /root/.nexus/network-api/clients/cli/target/release/nexus-network /root/.nexus/nexus-network

lsb_release -a
rustc --version
cargo --version

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"