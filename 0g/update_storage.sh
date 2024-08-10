#!/bin/bash
echo "-----------------------------------------------------------------------------"
echo "Выполняем обновление"
echo "-----------------------------------------------------------------------------"
source $HOME/.profile

cd $HOME/0g-storage-node/
git checkout -- run/config.toml
git tag -d $1 > /dev/null 2>&1
git fetch --all --tags
git checkout tags/$1 --force
git submodule update --init
sudo systemctl stop 0g_storage
cargo build --release
echo "-----------------------------------------------------------------------------"
echo "Настраиваем переменные"
echo "-----------------------------------------------------------------------------"
# Получение приватного ключа
PRIVATE_KEY=$($HOME/go/bin/0gchaind keys unsafe-export-eth-key wallet2 --keyring-backend test)
#Получаем IP
ENR_ADDR=$(wget -qO- eth0.me)

echo export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log" >> ~/.bash_profile
echo export ZGS_LOG_CONFIG_FILE="$HOME/0g-storage-node/run/log_config" >> ~/.bash_profile
echo export ENR_ADDR=${ENR_ADDR} >> ~/.bash_profile
echo export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768" >> ~/.bash_profile
echo export MINE_CONTRACT="0x6815F41019255e00D6F34aAB8397a6Af5b6D806f" >> ~/.bash_profile
echo export REWARD CONTRACT="0x51998C4d486F406a788B766d93510980ae1f9360" >> ~/.bash_profile
source ~/.bash_profile

echo -e "ZGS_LOG_DIR: $ZGS_LOG_DIR\nZGS_LOG_CONFIG_FILE: $ZGS_LOG_CONFIG_FILE\nENR_ADDR: $ENR_ADDR"
echo "-----------------------------------------------------------------------------"
echo "Обновляем config.toml"
echo "-----------------------------------------------------------------------------"

sed -i 's|# log_config_file = "log_config"|log_config_file = "'"$ZGS_LOG_CONFIG_FILE"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# log_directory = "log"|log_directory = "'"$ZGS_LOG_DIR"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^\s*#\?\s*network_enr_address\s*=\s*".*"\s*|network_enr_address = "'"$ENR_ADDR"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# mine_contract_address = ".*"|mine_contract_address = "'"$MINE_CONTRACT"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^#\? *log_sync_start_block_number = [0-9]\+|log_sync_start_block_number = 595059|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^#\? *confirmation_block_count = [0-9]\+|confirmation_block_count = 6|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# log_contract_address = ".*"|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_dir = "network"|network_dir = "network"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_enr_tcp_port = 1234|network_enr_tcp_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_enr_udp_port = 1234|network_enr_udp_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_libp2p_port = 1234|network_libp2p_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_discovery_port = 1234|network_discovery_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_boot_nodes = \[\]|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS", "/ip4/18.162.65.205/udp/1234/p2p/16Uiu2HAm2k6ua2mGgvZ8rTMV8GhpW71aVzkQWy7D37TTDuLCpgmX"\]|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# db_dir = "db"|db_dir = "db"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# blockchain_rpc_endpoint = "http://127.0.0.1:8545"|blockchain_rpc_endpoint = "http://127.0.0.1:8545"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# rpc_enabled = true|rpc_enabled = true|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# auto_sync_enabled = false|auto_sync_enabled = true|' $HOME/0g-storage-node/run/config.toml
sed -i '/# shard_position = "0\/2"/a reward_contract_address = "'"$REWARD_CONTRACT"'"' $HOME/0g-storage-node/run/config.toml
sed -i '/# shard_position = "0\/2"/a reward_contract_address = "'"$REWARD_CONTRACT"'"' $HOME/0g-storage-node/run/config.toml
sed -i 's|^#\? *db_max_num_chunks = [0-9]\+|db_max_num_chunks = 1000000000|' $HOME/0g-storage-node/run/config.toml

#sed -i 's/debug/info/; s/h2=info/h2=warn/' $HOME/0g-storage-node/run/log_config

#latest_block=$($HOME/go/bin/0gchaind status | jq -r .sync_info.latest_block_height)
#sed -i 's/log_sync_start_block_number = [0-9]\+/log_sync_start_block_number = '"$latest_block"'/g' $HOME/0g-storage-node/run/config.toml

rm -rf $HOME/0g-storage-node/run/db
rm -rf $HOME/0g-storage-node/run/network
rm -rf $HOME/0g-storage-node/run/log

sudo systemctl restart 0g_storage

echo "0G Storage Node успешно обновлена"
echo "-----------------------------------------------------------------------------"