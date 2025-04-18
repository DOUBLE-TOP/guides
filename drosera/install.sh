#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-20 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
sudo apt install iptables jq gcc automake autoconf nvme-cli libgbm1 pkg-config libleveldb-dev tar bsdmainutils libleveldb-dev  -y &>/dev/null
echo "Dependencies установлены"

# создаем файл .profile если его нет в системе
[ -f /root/.profile ] || touch /root/.profile

# Проверяем в системе git user.name
if ! git config --global user.name > /dev/null; then
  read -p "Введите Git user name: " name
  git config --global user.name "$name"
fi

# Проверяем в системе git user.email
if ! git config --global user.email > /dev/null; then
  read -p "Введите Git email: " email
  git config --global user.email "$email"
fi

echo "Ставим Drosera CLI"
curl -s -L https://app.drosera.io/install | bash > /dev/null 2>&1
echo 'export PATH="$PATH:/root/.drosera/bin"' >> /root/.profile
source /root/.profile
droseraup &>/dev/null

echo "Ставим Foundry CLI"
curl -s -L https://foundry.paradigm.xyz | bash &>/dev/null
echo 'export PATH="$PATH:/root/.foundry/bin"' >> /root/.profile
source /root/.profile
foundryup &>/dev/null

curl -fsSL https://bun.sh/install | bash &>/dev/null
echo 'export BUN_INSTALL="$HOME/.bun"' >> /root/.profile
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /root/.profile
source /root/.profile

echo "Создаем и компилируем Trap"
mkdir -p drosera
cd drosera
forge init -t drosera-network/trap-foundry-template &>/dev/null
bun install &>/dev/null
source /root/.bashrc
forge build &>/dev/null

echo "Размещаем Trap"
read -p "Введите адрес кошелька (начинается с 0х): " pubkey
read -p "Введите приватник данного кошелька: " privkey
read -p "Введите адресс вашей существующей Трапы (или нажмите Enter чтобы создать новую): " existing_trap

if [ -n "$existing_trap" ]; then
    echo "Вписали $existing_trap в файл drosera.toml"
    echo "address = \"$existing_trap\"" >> drosera.toml
else
    echo "Созадаем новую трапу."
fi

#DROSERA_PRIVATE_KEY="$privkey" drosera apply
#drosera dryrun

echo "Обновляем Drosera.toml whitelist"
sed -i "s/^whitelist = .*/whitelist = [\"$pubkey\"]/" drosera.toml
# Check if the line starting with 'private_trap' exists
if grep -q "^private_trap" drosera.toml; then
    sed -i 's/^private_trap.*/private_trap = true/' drosera.toml
else
    echo 'private_trap = true' >> drosera.toml
fi

#echo 'address = "0x64A135dFb1DF9C23C7193EFc8C3D53f4142A626C"' >> drosera.toml

DROSERA_PRIVATE_KEY="$privkey" drosera apply
drosera dryrun
echo "Сделали Трапу приватной и приязали к кошельку"
echo "Устанавливаем CLI оператора"
cd ~
curl -s -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz &>/dev/null
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz &>/dev/null
./drosera-operator --version
rm drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
sudo cp drosera-operator /usr/bin

drosera-operator register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key "$privkey"

echo "Оператор установлен. Создаем системный сервис"
ip_address=$(hostname -I | awk '{print $1}')

# удаляем сервис если уже стоит
if systemctl list-units --type=service --all | grep -q drosera.service; then
    sudo systemctl stop drosera.service
    sudo systemctl disable drosera.service
    if [ -f /etc/systemd/system/drosera.service ]; then
        sudo rm /etc/systemd/system/drosera.service
    fi
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi

sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=drosera node service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
    --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com \
    --eth-backup-rpc-url https://1rpc.io/holesky \
    --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 \
    --eth-private-key $privkey \
    --listen-address 0.0.0.0 \
    --network-external-p2p-address $ip_address \
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo "Установка завершена. Сервис запущен. Смотреть логи можно через journalctl -u drosera.service -f"
