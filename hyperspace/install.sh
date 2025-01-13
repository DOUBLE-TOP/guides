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

RED='\033[0;31m'
RESET="\033[0m"
response=$(curl -s "https://api.github.com/repos/hyperspaceai/aios-cli/releases/latest")

# Check if the response contains a rate limit error
if echo "$response" | grep -q "API rate limit exceeded"; then
    echo "Введите Гитхаб токен"
    read GITHUB_TOKEN

    curl -o install_script.sh https://download.hyper.space/api/install
    chmod +x install_script.sh
    sed -i "s|curl|curl -H \"Authorization: token $GITHUB_TOKEN\"|" install_script.sh
    bash install_script.sh --verbose
    rm install_script.sh
else
    curl https://download.hyper.space/api/install --verbose | bash
fi

source /root/.bashrc

# Проверка наличия директории
if [[ ! -d "$HOME/.aios" ]]; then
    echo "Установка ноды прервана из-за недоступности серверов Hyperspace. Перезапустите скрипт установки позже."
    exit 1  # Завершение скрипта с кодом 1
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
        echo "-----------------------------------------------------------------------------"
        echo "Настройка ноды"
        echo "-----------------------------------------------------------------------------"

        $HOME/.aios/aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf
        $HOME/.aios/aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf

        sudo systemctl restart aios

        $HOME/.aios/aios-cli hive whoami
        break
    fi
    
    if [[ SECONDS -ge end_time ]]; then
        echo -e "${LIGHT_BLUE}Установка ноды прервана из-за недоступности серверов Hyperspace. Перезапустите скрипт установки позже.${RESET}"
        systemctl stop aios
        systemctl disable aios
        rm -rf /etc/systemd/system/aios.service
        rm -rf $HOME/.aios
        rm -rf $HOME/.cache/hyperspace
        rm -rf $HOME/.config/hyperspace
        
        exit 1
    fi
done
echo "-----------------------------------------------------------------------------"
echo "Вывод ключей"
echo "\$HOME/.aios/aios-cli hive whoami"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u aios -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"