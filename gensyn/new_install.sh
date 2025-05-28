#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-20 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
apt-get install python3 python3-pip python3-venv python3-dev -y &>/dev/null

# Get the current Python version (major.minor format)
current_version=$(python3 --version 2>&1 | awk '{print $2}')
required_version="3.13"

if [[ "$(echo -e "$current_version\n$required_version" | sort -V | head -n1)" != "$required_version" ]]; then
    echo "Python версия ниже за 3.13. Устанавливаю Python 3.13..."
    sudo apt install -y software-properties-common &>/dev/null
    sudo add-apt-repository -y ppa:deadsnakes/ppa &>/dev/null
    sudo apt update &>/dev/null
    sudo apt install -y python3.13 python3.13-venv python3.13-dev &>/dev/null
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 13
    #sudo update-alternatives --set python3 /usr/bin/python3.13
    curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.13 &>/dev/null
fi

SERVICE_NAME="gensyn.service"
if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME"; then
    echo "Нашли существующий сервис gensyn, останавливаем..."
    sudo systemctl stop "$SERVICE_NAME"
    pkill next-server
fi

FOLDER="rl-swarm"
PEM_FILE="swarm.pem"

if [[ -f "$FOLDER/$PEM_FILE" ]]; then
    echo "Нашли файл $PEM_FILE в $FOLDER. Копирую в /root/..."
    cp "$FOLDER/$PEM_FILE" /root/
    echo "Бекап $PEM_FILE сохранен - /root/$PEM_FILE."
fi

if [ -d "$FOLDER" ]; then
    echo "Удаляем папку $FOLDER перед установкой."
    rm -rf "$FOLDER"
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js не установлена. Устанавливаем..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Get Node.js version
NODE_VERSION=$(node -v 2>/dev/null | cut -d 'v' -f 2)

# Check if the version is lower than 20.18.0
if [[ -n "$NODE_VERSION" && $(echo -e "$NODE_VERSION\n20.18.0" | sort -V | head -n1) == "$NODE_VERSION" ]]; then
    echo "Версия NodeJS ниже 20.18.0 ($NODE_VERSION). Обновляем..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1
    sudo apt install -y nodejs >/dev/null 2>&1
    echo "NodeJS обновлена: "
    node -v
fi

NODE_VERSION=$(node -v 2>/dev/null | cut -d 'v' -f 2)
echo "Node.js версия  $NODE_VERSION. Продолжаем..."

#preinstall yarn, so its properly registered in ~/profile
if ! command -v yarn >/dev/null 2>&1; then
      echo "Yarn не установлен. Устанавливаем..."
      curl -o- -L https://yarnpkg.com/install.sh 2>/dev/null | sh >/dev/null 2>&1
      echo 'export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"' >> ~/.profile
      source ~/.profile
fi

echo "Клонируем GIT проекта..."
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"
git clone "$REPO_URL" &>/dev/null
cd rl-swarm || { echo "Failed to enter directory rl-swarm"; exit 1; }
if [[ -x /usr/bin/python3.13 ]]; then
    /usr/bin/python3.13 -m venv .venv
else
    python3 -m venv .venv
fi
source .venv/bin/activate


ROOT=$PWD

export PUB_MULTI_ADDRS
export PEER_MULTI_ADDRS
export HOST_MULTI_ADDRS
export IDENTITY_PATH
export CONNECT_TO_TESTNET
export ORG_ID
export HF_HUB_DOWNLOAD_TIMEOUT=120  # 2 minutes

# Check if public multi-address is given else set to default
DEFAULT_PUB_MULTI_ADDRS=""
PUB_MULTI_ADDRS=${PUB_MULTI_ADDRS:-$DEFAULT_PUB_MULTI_ADDRS}

# Check if peer multi-address is given else set to default
DEFAULT_PEER_MULTI_ADDRS="/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ" # gensyn coordinator node
PEER_MULTI_ADDRS=${PEER_MULTI_ADDRS:-$DEFAULT_PEER_MULTI_ADDRS}

# Check if host multi-address is given else set to default
DEFAULT_HOST_MULTI_ADDRS="/ip4/0.0.0.0/tcp/38331"
HOST_MULTI_ADDRS=${HOST_MULTI_ADDRS:-$DEFAULT_HOST_MULTI_ADDRS}

# Path to an RSA private key. If this path does not exist, a new key pair will be created.
# Remove this file if you want a new PeerID.
DEFAULT_IDENTITY_PATH="$ROOT"/swarm.pem
IDENTITY_PATH=${IDENTITY_PATH:-$DEFAULT_IDENTITY_PATH}

SMALL_SWARM_CONTRACT="0x69C6e1D608ec64885E7b185d39b04B491a71768C"
BIG_SWARM_CONTRACT="0x6947c6E196a48B77eFa9331EC1E3e45f3Ee5Fd58"

# Will ignore any visible GPUs if set.
CPU_ONLY=${CPU_ONLY:-""}

# Set if successfully parsed from modal-login/temp-data/userData.json.
ORG_ID=${ORG_ID:-""}

GREEN_TEXT="\033[32m"
BLUE_TEXT="\033[34m"
RESET_TEXT="\033[0m"

echo_green() {
    echo -e "$GREEN_TEXT$1$RESET_TEXT"
}

echo_blue() {
    echo -e "$BLUE_TEXT$1$RESET_TEXT"
}

ROOT_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"

echo -e "\033[38;5;224m"
cat << "EOF"
    ██████  ██            ███████ ██     ██  █████  ██████  ███    ███
    ██   ██ ██            ██      ██     ██ ██   ██ ██   ██ ████  ████
    ██████  ██      █████ ███████ ██  █  ██ ███████ ██████  ██ ████ ██
    ██   ██ ██                 ██ ██ ███ ██ ██   ██ ██   ██ ██  ██  ██
    ██   ██ ███████       ███████  ███ ███  ██   ██ ██   ██ ██      ██

    From Gensyn

EOF

while true; do
    echo -en $GREEN_TEXT
    read -p ">> Which swarm would you like to join (Math (A) or Math Hard (B))? [A/b] " ab
    echo -en $RESET_TEXT
    ab=${ab:-A}  # Default to "A" if the user presses Enter
    case $ab in
        [Aa]*)  USE_BIG_SWARM=false && break ;;
        [Bb]*)  USE_BIG_SWARM=true && break ;;
        *)  echo ">>> Please answer A or B." ;;
    esac
done
if [ "$USE_BIG_SWARM" = true ]; then
    SWARM_CONTRACT="$BIG_SWARM_CONTRACT"
else
    SWARM_CONTRACT="$SMALL_SWARM_CONTRACT"
fi

while true; do
    echo -en $GREEN_TEXT
    read -p ">> How many parameters (in billions)? [0.5, 1.5, 7, 32, 72] " pc
    echo -en $RESET_TEXT
    pc=${pc:-0.5}  # Default to "0.5" if the user presses Enter
    case $pc in
        0.5 | 1.5 | 7 | 32 | 72) PARAM_B=$pc && break ;;
        *)  echo ">>> Please answer in [0.5, 1.5, 7, 32, 72]." ;;
    esac
done

# rl-swarm code
    # run modal_login server
    cd modal-login

    echo "Запускаем yarn install (ориентировочное время 2-5 мин)"
    yarn install &>/dev/null
    yarn upgrade &>/dev/null
    yarn add next@latest react react-dom &>/dev/null
    yarn add viem@latest &>/dev/null
    yarn dev > /dev/null 2>&1 & # Run in background and suppress output
    echo "Установка завершена"
    echo "-----------------------------------------------------------------------------"
    echo ""

    # fix forever loading
    curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/refs/heads/main/gensyn/fix_login_loading_screen.sh | bash &>/dev/null
    
    echo "Please login to create an Ethereum Server Wallet"
    SERVER_PID=$!  # Store the process ID
    sleep 5
    #open http://localhost:3000
    cd ..

    # Wait until modal-login/temp-data/userData.json exists
    while [ ! -f "modal-login/temp-data/userData.json" ]; do
        echo "Ждем авторизацию (localhost:3000)..."
        sleep 5  # Wait for 5 seconds before checking again
    done
    echo "Авторизировано. Продолжаем..."

    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' modal-login/temp-data/userData.json)
    echo "Your ORG_ID is set to: $ORG_ID"

    # Function to clean up the server process
    cleanup() {
        echo_green ">> Shutting down trainer..."
        kill $SERVER_PID
        rm -r modal-login/temp-data/*.json
        exit 0
    }

    # Set up trap to catch Ctrl+C and call cleanup
    #trap cleanup EXIT

    echo "Ждем активацию API ключа..."
    while true; do
        STATUS=$(curl -s "http://localhost:3000/api/get-api-key-status?orgId=$ORG_ID")
        if [[ "$STATUS" == "activated" ]]; then
            echo "API ключ активирован! Продолжаем..."
            break
        else
            echo "Ждем активацию API ключа..."
            sleep 5
        fi
    done
    ENV_FILE="$ROOT"/modal-login/.env
    sed -i "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"

if [[ -f "/root/$PEM_FILE" ]]; then
    echo "Нашли бекап файла $PEM_FILE в /root/. Копирую в папку проекта $ROOT..."
    cp "/root/$PEM_FILE" "$ROOT/"
fi

#lets go!
echo "Ставим python dependencies (5-15 мин)..."
pip install --upgrade pip &>/dev/null

if [ -n "$CPU_ONLY" ] || ! command -v nvidia-smi &> /dev/null; then
    # CPU-only mode or no NVIDIA GPU found
    pip install -r "$ROOT"/requirements-cpu.txt &>/dev/null
    #pip install hf_xet &>/dev/null
    CONFIG_PATH="$ROOT/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml" # TODO: Fix naming.
    GAME="gsm8k"
else
    # NVIDIA GPU found
    pip install -r "$ROOT"/requirements-gpu.txt &>/dev/null
    pip install flash-attn --no-build-isolation &>/dev/null

    case "$PARAM_B" in
        32 | 72) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-bnb-4bit-deepseek-r1.yaml" && break ;;
        0.5 | 1.5 | 7) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-deepseek-r1.yaml" && break ;;
        *)  echo ">>> Please answer in [0.5, 1.5, 7, 32, 72]." ;;
    esac
    if [ "$USE_BIG_SWARM" = true ]; then
        GAME="dapo"
    else
        GAME="gsm8k"
    fi
fi

echo ">> Готово!"
echo ""
echo ""

if [ -n "${HF_TOKEN}" ]; then # Check if HF_TOKEN is already set and use if so. Else give user a prompt to choose.
   HUGGINGFACE_ACCESS_TOKEN=${HF_TOKEN}
else
   read -p "Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N] " yn
   yn=${yn:-N}  # Default to "N" if the user presses Enter
   case $yn in
      [Yy]* ) read -p "Enter your Hugging Face access token: " HUGGINGFACE_ACCESS_TOKEN;;
      [Nn]* ) HUGGINGFACE_ACCESS_TOKEN="None";;
      * ) echo ">>> No answer was given, so NO models will be pushed to Hugging Face Hub" && HUGGINGFACE_ACCESS_TOKEN="None";;
   esac
fi

echo ""
echo ""
echo_green "Good luck in the swarm!"
# end official script part

# делаем скрипт для будущего systemd сервиса
OUTPUT_SCRIPT="$ROOT/gensyn_service.sh"

if [ -n "$ORG_ID" ]; then
cat <<EOF > "$OUTPUT_SCRIPT"
#!/bin/bash

# Set working directory
FOLDER="$ROOT"
cd "\$FOLDER" || exit 1

source /root/.profile
source .venv/bin/activate

pkill next-server

cd modal-login
yarn install
yarn dev > /dev/null 2>&1 &
cd ..

# Set parameters
HUGGINGFACE_ACCESS_TOKEN="$HUGGINGFACE_ACCESS_TOKEN"
IDENTITY_PATH="$IDENTITY_PATH"
ORG_ID="$ORG_ID"
CONFIG_PATH="$CONFIG_PATH"
SWARM_CONTRACT="$SWARM_CONTRACT"
GAME="$GAME"

    python -m hivemind_exp.gsm8k.train_single_gpu \
        --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
        --identity_path "$IDENTITY_PATH" \
        --modal_org_id "$ORG_ID" \
        --contract_address "$SWARM_CONTRACT" \
        --config "$CONFIG_PATH" \
        --game "$GAME"

wait
EOF
else
cat <<EOF > "$OUTPUT_SCRIPT"
#!/bin/bash

# Set working directory
FOLDER="$ROOT"
cd "\$FOLDER" || exit 1

source /root/.profile
source .venv/bin/activate

pkill next-server


# Set parameters
HUGGINGFACE_ACCESS_TOKEN="$HUGGINGFACE_ACCESS_TOKEN"
IDENTITY_PATH="$IDENTITY_PATH"
CONFIG_PATH="$CONFIG_PATH"
PUB_MULTI_ADDRS="$PUB_MULTI_ADDRS"
PEER_MULTI_ADDRS="$PEER_MULTI_ADDRS"
HOST_MULTI_ADDRS="$HOST_MULTI_ADDRS"
GAME="$GAME"

    python -m hivemind_exp.gsm8k.train_single_gpu \
        --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
        --identity_path "$IDENTITY_PATH" \
        --public_maddr "$PUB_MULTI_ADDRS" \
        --initial_peers "$PEER_MULTI_ADDRS" \
        --host_maddr "$HOST_MULTI_ADDRS" \
        --config "$CONFIG_PATH" \
        --game "$GAME"

wait
EOF
fi
chmod +x "$OUTPUT_SCRIPT"
echo "Скрипт для systemd сервиса создан: $OUTPUT_SCRIPT"

# создаем сам сервис в системе
SERVICE_NAME="gensyn.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
LOG_FILE="/var/log/gensyn.log"
ERROR_LOG_FILE="/var/log/gensyn_error.log"

# удаляем сервис если уже стоит
if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm "$SERVICE_FILE"
    fi
    > "$ERROR_LOG_FILE"
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi


# Create the systemd service file
cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Gensyn Service
After=network.target

[Service]
User=root
WorkingDirectory=$ROOT
ExecStart=/bin/bash $ROOT/gensyn_service.sh
Restart=always
RestartSec=5
StandardOutput=append:$LOG_FILE
StandardError=append:$ERROR_LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable gensyn.service
sudo systemctl start gensyn.service

sleep 10
cp "$ROOT/modal-login/temp-data/userApiKey.json" "$ROOT/userApiKey_backup.json"
cp "$ROOT/modal-login/temp-data/userData.json" "$ROOT/userData_backup.json"

echo "systemd сервис создан и запущен."
echo "Смотреть логи можно командой: tail -n 20 -f $ERROR_LOG_FILE"
