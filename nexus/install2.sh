#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add riscv32i-unknown-none-elf

sudo apt install -y protobuf-compiler

curl https://cli.nexus.xyz/ | sh

source /root/.bashrc

# Get the major.minor version number of glibc from ldd
version_str=$(ldd --version | head -n1)
# Extract version number like "2.35" or "2.39"
version_num=$(echo "$version_str" | grep -oP '\d+\.\d+' | head -n1)
version_lt() {
    # Use sort -V (version sort)
    [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}
REQUIRED_VERSION="2.39"

if version_lt "$version_num" "$REQUIRED_VERSION"; then
    echo "Ставим $REQUIRED_VERSION. Ориентировочное время 10-20 минут."
    curl -fsSL https://raw.githubusercontent.com/DOUBLE-TOP/tools/refs/heads/main/glibc239.sh | bash &>/dev/null
fi

echo "Установка Nexus завершена. Продолжайте по гайду"
