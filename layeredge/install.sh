#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-30 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

echo "Удаляем Go..."
sudo rm -rf /usr/local/go
rm -rf ~/go ~/.cache/go-build ~/.config/go
sudo apt remove --purge -y golang-go &>/dev/null
sudo apt autoremove -y &>/dev/null
sudo snap remove go 2>/dev/null || true
sed -i '/\/usr\/local\/go\/bin/d' ~/.profile ~/.bashrc ~/.zshrc 2>/dev/null || true

echo "Устанавливаем Go"
wget https://golang.org/dl/go1.22.1.linux-amd64.tar.gz &>/dev/null
sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz &>/dev/null
rm go1.22.1.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.bashrc
source ~/.profile
echo "Go установлена: $(go version)"

echo "Удаляем Rust and Cargo..."
rustup self uninstall -y 2>/dev/null || true
rm -rf ~/.cargo ~/.rustup
sudo apt remove --purge -y rustc cargo &>/dev/null
sudo apt autoremove -y &>/dev/null
sed -i '/\.cargo\/bin/d' ~/.bashrc ~/.zshrc 2>/dev/null || true

echo "Устанавливаем Rust и Cargo..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
source $HOME/.cargo/env
echo "Rust установлен: $(rustc --version)"
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

function get_private_key() {
  while true; do
    read -p "Введите private key вашего кошелька (без 0х): " private_key_value

    # Check if the private key starts with "0x"
    if [[ $private_key_value == 0x* ]]; then
      echo "Error: Private key should not start with '0x'. Please try again."
    else
      echo "Private key accepted."
      break
    fi
  done
}

get_private_key


curl -L https://risczero.com/install | bash &>/dev/null && rzup install &>/dev/null
source ~/.bashrc
if [ -d "light-node" ]; then
  rm -rf "light-node"
fi
git clone https://github.com/Layer-Edge/light-node.git &>/dev/null
cd light-node

cat > .env <<EOL
GRPC_URL=grpc.testnet.layeredge.io:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=https://layeredge.mintair.xyz/
API_REQUEST_TIMEOUT=100
POINTS_API=https://light-node.layeredge.io
PRIVATE_KEY='${private_key_value}'
EOL

echo ".env файл создан"
cd risc0-merkle-service
# kill risc service if it exists
if tmux has-session -t risc_service 2>/dev/null; then
    tmux kill-session -t risc_service
fi
tmux new-session -d -s risc_service "cargo build && cargo run"
echo "risc0 сервис запущен (tmux session risc_service)"
echo "-----------------------------------------------------------------------------"
echo "Начинаю билдить Go (~2-5 мин)"
echo "-----------------------------------------------------------------------------"
cd ..
go build &>/dev/null
echo "Сбилдили light-node, запускаем как systemd сервис"

SERVICE_NAME="light-node"
EXECUTABLE_PATH="/root/light-node/light-node"  # Change this to the actual path
WORKING_DIR="/root/light-node/"                # Change this to the actual working directory
LOG_FILE="/var/log/light_node.log"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

> "$LOG_FILE"
# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Check if the service exists
if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME.service"; then
    echo "Найден существующий сервис '$SERVICE_NAME'. Удаляем..."
    # Stop the service if it's running
    sudo systemctl stop $SERVICE_NAME
    # Disable the service so it doesn’t start on boot
    sudo systemctl disable $SERVICE_NAME
    # Remove the systemd service file
    sudo rm -f $SERVICE_FILE
    # Reload systemd
    sudo systemctl daemon-reload

    echo "Сервис '$SERVICE_NAME' удален."
fi

cat <<EOF > $SERVICE_FILE
[Unit]
Description=Light Node Service
After=network.target

[Service]
ExecStart=$EXECUTABLE_PATH
Restart=always
RestartSec=60
User=root
WorkingDirectory=$WORKING_DIR
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

chmod 644 $SERVICE_FILE

echo "Перезапускаем systemd"
systemctl daemon-reload
systemctl enable $SERVICE_NAME

echo "Стартуем сервис $SERVICE_NAME"
systemctl start $SERVICE_NAME

#./light-node >> /var/log/light_node.log 2>&1 &
echo "light-node запущена, ждем свой public key"

# Ждем и покажем public key когда стартанет
log_file="/var/log/light_node.log"

check_public_key() {
  parsed_key=$(tail -n 1000 "$log_file" | grep -oP 'Compressed Public Key: \K[0-9a-fA-F]+')

  if [[ -n "$parsed_key" ]]; then
    echo "Ваш Public Key: $parsed_key"
    return 0  # Success
  else
    return 1  # Not found
  fi
}

while true; do
  if check_public_key; then
    break
  else
    echo "Ждем Public Key..."
    sleep 30
  fi
done
