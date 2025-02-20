#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

sudo apt purge -y protobuf-compiler

ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    PROTOC_VERSION="25.2"
    PROTOC_URL="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip"
elif [[ "$ARCH" == "aarch64" ]]; then
    PROTOC_VERSION="3.19.1"
    PROTOC_URL="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-aarch_64.zip"
else
    echo "Архитектура $ARCH не поддерживается."
    exit 1
fi

curl -LO "$PROTOC_URL"
unzip "protoc-${PROTOC_VERSION}-linux-*.zip" -d "$HOME/.local"
# curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-x86_64.zip
# unzip protoc-25.2-linux-x86_64.zip -d $HOME/.local
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
protoc --version

rustup target add riscv32i-unknown-none-elf

# remove previous data
systemctl stop nexus &>/dev/null
systemctl disable nexus &>/dev/null
rm -rf $HOME/.nexus /etc/systemd/system/nexus.service 
source .profile

# swap file fix
SWAP_LOCATE=$(swapon --show | awk 'NR==2 {print $1}')
if [[ -n "$SWAP_LOCATE" ]]; then
    swapoff "$SWAP_LOCATE" && rm -f "$SWAP_LOCATE"
fi
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

# wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip
# unzip protoc-21.12-linux-x86_64.zip -d $HOME/.local
# export PATH="$HOME/.local/bin:$PATH"

cargo clean
RUST_BACKTRACE=1 cargo build --release

cp /root/.nexus/network-api/clients/cli/target/release/nexus-network /root/.nexus/nexus-network

lsb_release -a
rustc --version
cargo --version
file $HOME/.local/bin/protoc

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"