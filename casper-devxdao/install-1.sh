#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

CASPER_VERSION=1_0_0
CASPER_NETWORK=casper-test

sudo apt-get update
sudo apt install dnsutils jq mc git -y

echo "deb https://repo.casperlabs.io/releases" bionic main | sudo tee -a /etc/apt/sources.list.d/casper.list
curl -O https://repo.casperlabs.io/casper-repo-pubkey.asc
sudo apt-key add casper-repo-pubkey.asc
sudo apt update --allow-insecure-repositories


sudo apt install -o APT::Get::AllowUnauthenticated=true casper-node-launcher -y
sudo apt install -o APT::Get::AllowUnauthenticated=true casper-client -y

cd ~
sudo apt purge --auto-remove cmake -y
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main'
sudo apt update
sudo apt install cmake -y

sudo curl https://sh.rustup.rs -sSf | sh -s -- -y

sudo apt install libssl-dev -y
sudo apt install pkg-config -y
sudo apt install build-essential -y

BRANCH="1.0.20" \
    && git clone --branch ${BRANCH} https://github.com/WebAssembly/wabt.git "wabt-${BRANCH}" \
    && cd "wabt-${BRANCH}" \
    && git submodule update --init \
    && cd - \
    && cmake -S "wabt-${BRANCH}" -B "wabt-${BRANCH}/build" \
    && cmake --build "wabt-${BRANCH}/build" --parallel 8 \
    && sudo cmake --install "wabt-${BRANCH}/build" --prefix /usr --strip -v \
    && rm -rf "wabt-${BRANCH}"

cd ~
git clone git://github.com/CasperLabs/casper-node.git
cd casper-node/
git checkout release-1.0.0
make setup-rs
make build-client-contracts -j

echo "##########################################"
echo "Environment install finished"
echo "In next step you need to move old keys from Casper or generate new"
echo "##########################################"
