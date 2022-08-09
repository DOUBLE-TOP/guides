#!/bin/bash
#rm -rf $HOME/Bit-Country-Blockchain &>/dev/null
#rm -rf $HOME/.local/share/bitcountry-node/chains/tewai_testnet/db/ &>/dev/null

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source $HOME/.profile &>/dev/null
source $HOME/.bashrc &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
mkdir -p $HOME/bitcountry_bk/
cp $HOME/.local/share/metaverse-node/chains/tewai_testnet/network/secret_ed25519 $HOME/bitcountry_bk/secret_ed25519_metaverse
cp $HOME/.local/share/bitcountry-node/chains/tewai_testnet/network/secret_ed25519 $HOME/bitcountry_bk/secret_ed25519_bitcountry

if [ ! -d $HOME/Metaverse-Network/ ]; then
  git clone https://github.com/bit-country/Metaverse-Network.git &>/dev/null
fi
cd $HOME/Metaverse-Network
git fetch
git stash
git checkout 372678324f5543e527591f68b128ff6919267558 &>/dev/null
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"

make init &>/dev/null
cargo build --release --features=with-tewai-runtime &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl restart bitcountry

echo "Нода обновилена и запущена"
echo "-----------------------------------------------------------------------------"
