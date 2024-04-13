#!/bin/bash
#Устанавливаем тулы и билдим сторадж
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh)
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)

git clone https://github.com/0glabs/0g-storage-node.git
cd 0g-storage-node
git submodule update --init
cargo build --release


#Генерим ключ и майнер адресс

# Generate a random 32-byte private key
private_key=$(openssl rand -hex 32)

# Generate a corresponding public key (Elliptic Curve Cryptography)
# This uses the secp256k1 curve, commonly used in Bitcoin.
openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout > key_details.txt
public_key=$(cat key_details.txt | grep pub -A 5 | tail -n +2 | tr -d '\n[:space:]:' | sed 's/^04//')

# Hash the public key using SHA256 to generate the Miner ID
miner_id=$(echo -n $public_key | xxd -r -p | openssl dgst -sha256)

# Output the private key and Miner ID
echo "Private Key: $private_key"
echo "Miner ID: $miner_id"

# Update config.toml file with the new Miner ID and Private Key
config_file="$HOME/0g-storage-node/run/config.toml"
sed -i "s/miner_id = \"\"/miner_id = \"$miner_id\"/" $config_file
sed -i "s/miner_key = \"\"/miner_key = \"$private_key\"/" $config_file

echo "Updated config.toml with new Miner ID and Private Key."

# cd $HOME/0g-storage-node/run
# ../target/release/zgs_node --config config.toml

sudo tee <<EOF >/dev/null /etc/systemd/system/0g_storage.service
[Unit]
  Description=OG Storage daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
  WorkingDirectory=$HOME/0g-storage-node/run
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=65535
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable 0g_storage &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart 0g_storage
