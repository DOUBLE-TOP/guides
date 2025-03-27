#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
install_0gchaind() {
    echo "Installing 0gchaind..."
    cd $HOME
    source $HOME/.profile
    git clone https://github.com/0glabs/0g-chain.git
    cd 0g-chain
    git checkout v0.5.2
    make install
    0gchaind version
}

# Проверка наличия 0gchaind
if [ ! -f "$HOME/go/bin/0gchaind" ]; then
    install_0gchaind
else
    echo "Бинарник 0gchaind установлен."
fi

# Запрос у пользователя
echo "Вы хотите восстановить кошелек который вы использовали для валиадтора или создать новый ?"
echo "1 - Восстановить кошелек"
echo "2 - Новый кошелек"
read -p "Введите 1 или 2: " choice

case $choice in
    1)
        echo "Восстановление кошелька..."
        # Команда для восстановления кошелька
        read -p "Введите вашу мнемоническую фразу: " mnemonic
        0gchaind keys delete wallet2 --keyring-backend test -y &>/dev/null
        0gchaind keys add wallet2 --recover --eth --keyring-backend test <<< "$mnemonic"
        ;;
    2)
        echo "Создание нового кошелька..."
        # Команда для создания нового кошелька
        0gchaind keys delete wallet2 --keyring-backend test -y &>/dev/null
        0gchaind keys add wallet2 --eth --keyring-backend test
        ;;
    *)
        echo "Неверный выбор. Пожалуйста, запустите сценарий еще раз и выберите 1 или 2."
        exit 1
        ;;
esac
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt upgrade -y 
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh) &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget build-essential git jq make gcc tmux chrony lz4 unzip ncdu htop -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
cd $HOME
git clone -b v0.8.4 https://github.com/0glabs/0g-storage-node.git
cd 0g-storage-node
git submodule update --init
cargo build --release
echo "Репозиторий успешно склонирован, начинаем настройку переменных"
echo "-----------------------------------------------------------------------------"
# Получение приватного ключа
PRIVATE_KEY=$($HOME/go/bin/0gchaind keys unsafe-export-eth-key wallet2 --keyring-backend test)
ADDRES=$(echo "0x$(0gchaind debug addr $(0gchaind keys show wallet2 -a --keyring-backend test) | grep hex | awk '{print $3}')")
#Получаем IP
ENR_ADDR=$(wget -qO- eth0.me)

echo export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log" >> ~/.bash_profile
echo export ZGS_LOG_CONFIG_FILE="$HOME/0g-storage-node/run/log_config" >> ~/.bash_profile
echo export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768" >> ~/.bash_profile
echo export MINE_CONTRACT="0x6815F41019255e00D6F34aAB8397a6Af5b6D806f" >> ~/.bash_profile
echo export REWARD_CONTRACT="0x51998C4d486F406a788B766d93510980ae1f9360" >> ~/.bash_profile
echo export ENR_ADDR=${ENR_ADDR} >> ~/.bash_profile
source ~/.bash_profile

echo -e "ZGS_LOG_DIR: $ZGS_LOG_DIR\nZGS_LOG_CONFIG_FILE: $ZGS_LOG_CONFIG_FILE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nENR_ADDR: $ENR_ADDR"

sed -i 's|# log_config_file = "log_config"|log_config_file = "'"$ZGS_LOG_CONFIG_FILE"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# log_directory = "log"|log_directory = "'"$ZGS_LOG_DIR"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# mine_contract_address = ".*"|mine_contract_address = "'"$MINE_CONTRACT"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# log_contract_address = ".*"|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^\s*#\?\s*network_enr_address\s*=\s*".*"\s*|network_enr_address = "'"$ENR_ADDR"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_dir = "network"|network_dir = "network"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_enr_tcp_port = 1234|network_enr_tcp_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_enr_udp_port = 1234|network_enr_udp_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_libp2p_port = 1234|network_libp2p_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_discovery_port = 1234|network_discovery_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_boot_nodes = \[\]|network_boot_nodes = \["/ip4/47.251.117.133/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/47.76.61.226/udp/1234/p2p/16Uiu2HAm2k6ua2mGgvZ8rTMV8GhpW71aVzkQWy7D37TTDuLCpgmX"]|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# db_dir = "db"|db_dir = "db"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# blockchain_rpc_endpoint = "http://127.0.0.1:8545"|blockchain_rpc_endpoint = "http://127.0.0.1:8545"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^#\? *log_sync_start_block_number = [0-9]\+|log_sync_start_block_number = 595059|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^#\? *confirmation_block_count = [0-9]\+|confirmation_block_count = 6|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# rpc_enabled = true|rpc_enabled = true|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^#\? *db_max_num_sectors = [0-9]\+|db_max_num_sectors = 1000000000|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# auto_sync_enabled = false|auto_sync_enabled = true|' $HOME/0g-storage-node/run/config.toml
sed -i '/# shard_position = "0\/2"/a reward_contract_address = "'"$REWARD_CONTRACT"'"' $HOME/0g-storage-node/run/config.toml

#sed -i 's/debug/info/; s/h2=info/h2=warn/' $HOME/0g-storage-node/run/log_config

#latest_block=$($HOME/go/bin/0gchaind status | jq -r .sync_info.latest_block_height)
#sed -i 's/log_sync_start_block_number = [0-9]\+/log_sync_start_block_number = '"$latest_block"'/g' $HOME/0g-storage-node/run/config.toml

echo "Переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee /etc/systemd/system/0g_storage.service > /dev/null <<EOF
[Unit]
Description=0G Storage Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable 0g_storage &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart 0g_storage

echo "0G Storage Node успешно установлена"
echo "Запросите в кране токенов на адрес - $ADDRES "
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
