#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh) &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем ноду"
echo "-----------------------------------------------------------------------------"

# 203,95

echo "Введите PRIVATE KEY"
read PRIVATE_KEY
# Check if it starts with "0x" and remove it
if [[ $PRIVATE_KEY == 0x* ]]; then
    PRIVATE_KEY="${PRIVATE_KEY:2}"
fi

echo "Введите Тир от 1 до 5 в зависимости от используемых ресурсов(RAM - оперативная память)"
echo "1 : 30GB"
echo "2 : 20GB"
echo "3 : 8GB"
echo "4 : 4GB"
echo "5 : 2GB"
read TIER

curl https://download.hyper.space/api/install | bash
source /root/.bashrc

sudo tee /etc/systemd/system/aios.service > /dev/null << EOF
[Unit]
Description=Hyperspace Aios Node
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/.aios/aios-cli start --connect
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo tee /$HOME/.aios/private_key.pem > /dev/null << EOF
$PRIVATE_KEY
EOF

sudo systemctl daemon-reload
sudo systemctl enable aios
sudo systemctl start aios

journalctl -n 100 -f -u aios -o cat | while read line; do
        if [[ "$line" == *"Authenticated successfully"* ]]; then
        echo "Log entry found: $line"
        break
    fi
done

echo "-----------------------------------------------------------------------------"
echo "Настройка ноды"
echo "-----------------------------------------------------------------------------"

cd $HOME/.aios/
aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf
aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf
aios-cli hive import-keys ./private_key.pem
aios-cli hive login
aios-cli hive select-tier $TIER
aios-cli hive infer --model hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf --prompt "Can you explain how to write an HTTP server in Rust?"

sudo systemctl restart aios

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u aios -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"