#!/bin/bash
echo "-----------------------------------------------------------------------------"
echo "Выполняем обновление"
echo "-----------------------------------------------------------------------------"
source $HOME/.profile

cd $HOME/0g-storage-node/
#cp run/config.toml $HOME/config.toml.bak
git checkout -- run/config.toml
git fetch --all --tags
git checkout tags/$1 --force
git submodule update --init
sudo systemctl stop 0g_storage
cargo build --release
#mv $HOME/config.toml.bak run/config.toml
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
source ~/.bash_profile

echo -e "ZGS_LOG_DIR: $ZGS_LOG_DIR\nZGS_LOG_CONFIG_FILE: $ZGS_LOG_CONFIG_FILE\nENR_ADDR: $ENR_ADDR"
echo "-----------------------------------------------------------------------------"
echo "Обновляем config.toml"
echo "-----------------------------------------------------------------------------"

sed -i 's|# log_config_file = "log_config"|log_config_file = "'"$ZGS_LOG_CONFIG_FILE"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# log_directory = "log"|log_directory = "'"$ZGS_LOG_DIR"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|^\s*#\?\s*network_enr_address\s*=\s*".*"\s*|network_enr_address = "'"$ENR_ADDR"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_dir = "network"|network_dir = "network"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_enr_tcp_port = 1234|network_enr_tcp_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_enr_udp_port = 1234|network_enr_udp_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_libp2p_port = 1234|network_libp2p_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# network_discovery_port = 1234|network_discovery_port = 1234|' $HOME/0g-storage-node/run/config.toml
sed -i 's|network_boot_nodes = \[\"/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmPxGNWu9eVAQPJww79J32pTJLKGcpjRMb4Qb8xxKkyuG1\",\"/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAm93Hd5azfhkGBbkx1zero3nYHvfjQYM2NtiW4R3r5bE2g\"\]|network_boot_nodes = \[\"/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps\",\"/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS\"\]|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# db_dir = "db"|db_dir = "db"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|blockchain_rpc_endpoint = "https://rpc-testnet.0g.ai"|blockchain_rpc_endpoint = "http://127.0.0.1:8545/"|' $HOME/0g-storage-node/run/config.toml
sed -i 's|# rpc_enabled = true|rpc_enabled = true|' $HOME/0g-storage-node/run/config.toml
sed -i 's|miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
sed -i 's/debug/info/; s/h2=info/h2=warn/' $HOME/0g-storage-node/run/log_config

rm -rf $HOME/0g-storage-node/run/db
rm -rf $HOME/0g-storage-node/run/network

sudo systemctl restart 0g_storage

echo "0G Storage Node успешно обновлена"
echo "-----------------------------------------------------------------------------"