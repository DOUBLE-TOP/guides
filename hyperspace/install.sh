#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh) &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем ноду"
echo "-----------------------------------------------------------------------------"

response=$(curl -s "https://api.github.com/repos/hyperspaceai/aios-cli/releases/latest")

# Check if the response contains a rate limit error
if echo "$response" | grep -q "API rate limit exceeded"; then
    echo "Введите Гитхаб токен"
    read GITHUB_TOKEN

    curl -o install_script.sh https://download.hyper.space/api/install
    chmod +x install_script.sh
    sed -i "s|curl|curl -H \"Authorization: token $GITHUB_TOKEN\"|" install_script.sh
    bash install_script.sh
    rm install_script.sh
else
    curl https://download.hyper.space/api/install | bash
fi

source /root/.bashrc

# Проверка наличия директории
if [[ ! -d "$HOME/.aios" ]]; then
    echo "Установка ноды прервана из-за недоступности серверов Hyperspace. Перезапустите скрипт установки позже."
    exit 1  # Завершение скрипта с кодом 1
fi

echo "Введите PRIVATE KEY"
read PRIVATE_KEY

# Check if it starts with "0x" and remove it
if [[ $PRIVATE_KEY == 0x* ]]; then
    PRIVATE_KEY="${PRIVATE_KEY:2}"
fi

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

sudo tee $HOME/.aios/private_key.pem > /dev/null << EOF
$PRIVATE_KEY
EOF

sudo systemctl daemon-reload
sudo systemctl enable aios
sudo systemctl start aios

end_time=$((SECONDS + 60))

journalctl -n 100 -f -u aios -o cat | while read line; do
    if [[ "$line" == *"Authenticated successfully"* ]]; then
        echo "Log entry found: $line"
        break
    fi
    
    if [[ SECONDS -ge end_time ]]; then
        echo "Установка ноды прервана из-за недоступности серверов Hyperspace. Перезапустите скрипт установки позже."
        echo "Выполните следующие команды, чтобы завершить установку:"
        echo "$HOME/.aios/aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf"
        echo "$HOME/.aios/aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf"
        echo "$HOME/.aios/aios-cli hive import-keys $HOME/.aios/private_key.pem"
        echo "$HOME/.aios/aios-cli hive login"
        echo "sudo systemctl restart aios"
        echo "-----------------------------------------------------------------------------"
        echo "Проверка логов"
        echo "journalctl -n 100 -f -u aios -o cat"
        echo "-----------------------------------------------------------------------------"
        echo "Wish lifechange case with DOUBLETOP"
        echo "-----------------------------------------------------------------------------"
        exit 1
    fi
done

echo "-----------------------------------------------------------------------------"
echo "Настройка ноды"
echo "-----------------------------------------------------------------------------"

$HOME/.aios/aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf
$HOME/.aios/aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf
$HOME/.aios/aios-cli hive import-keys $HOME/.aios/private_key.pem
$HOME/.aios/aios-cli hive login

sudo systemctl restart aios

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u aios -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"