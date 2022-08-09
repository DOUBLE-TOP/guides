#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt install curl -y &>/dev/null
sudo apt-get install curl wget jq libpq-dev libssl-dev build-essential pkg-config openssl ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
source $HOME/.profile
source "$HOME/.cargo/env"
mkdir $HOME/bundlr
cd $HOME/bundlr
git clone --recurse-submodules https://github.com/Bundlr-Network/validator-rust.git
cd $HOME/bundlr/validator-rust && cargo run --bin wallet-tool create > wallet.json
echo "-----------------------------------------------------------------------------"
echo -e "Создаем docker-compose файл"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null $HOME/bundlr/validator-rust/.env
PORT=2109
VALIDATOR_KEY=./wallet.json
BUNDLER_URL=https://testnet1.bundlr.network
GW_WALLET=./wallet.json
GW_CONTRACT=RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA
GW_ARWEAVE=https://arweave.testnet1.bundlr.network
EOF
cd $HOME/bundlr/validator-rust && docker-compose up -d
echo -e "Docker контейнер запущен"
echo "-----------------------------------------------------------------------------"
