#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт (временной диапазон ожидания ~5-15 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/refs/heads/main/docker.sh | bash &>/dev/null

yes | bash -i <(curl -s https://install.aztec.network) > /dev/null 2>&1

echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.profile
source ~/.bashrc
source ~/.profile

aztec-up latest

# stopping existing docker
docker ps -q --filter "ancestor=aztecprotocol/aztec" | xargs -r docker stop
# removing
docker ps -a -q --filter "ancestor=aztecprotocol/aztec" | xargs -r docker rm

mkdir -p aztec
cd aztec


# Get current server's IP
P2P_IP=$(curl -s ifconfig.me)

read -rp "Введите Sepolia Ethereum RPC URL: " RPC_URL
read -rp "Введите Beacon URL: " BEACON_URL
read -rp "Введите Ваш Private Key: " PRIVATE_KEY
read -rp "Введите Ваш Public Key: " ADDRESS

# PRIVATE_KEY starts with 0x
if [[ $PRIVATE_KEY != 0x* ]]; then
    PRIVATE_KEY="0x$PRIVATE_KEY"
fi

# ADDRESS starts with 0x
if [[ $ADDRESS != 0x* ]]; then
    ADDRESS="0x$ADDRESS"
fi

# Creating .env file
cat > .env <<EOF
ETHEREUM_RPC_URL=$RPC_URL
CONSENSUS_BEACON_URL=$BEACON_URL
VALIDATOR_PRIVATE_KEY=$PRIVATE_KEY
COINBASE=$ADDRESS
P2P_IP=$P2P_IP
EOF

# Creating docker-compose
cat > docker-compose.yml <<'EOF'
services:
  aztec-node:
    container_name: aztec-sequencer
    network_mode: host 
    image: aztecprotocol/aztec:latest
    restart: unless-stopped
    environment:
      ETHEREUM_HOSTS: ${ETHEREUM_RPC_URL}
      L1_CONSENSUS_HOST_URLS: ${CONSENSUS_BEACON_URL}
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEY: ${VALIDATOR_PRIVATE_KEY}
      COINBASE: ${COINBASE}
      P2P_IP: ${P2P_IP}
      LOG_LEVEL: debug
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'
    ports:
      - 40400:40400/tcp
      - 40400:40400/udp
      - 8080:8080
    volumes:
      - /root/.aztec/alpha-testnet/data/:/data
EOF

# launching docker
docker compose up -d

echo "Готово. Проверяем логи командой: docker logs -f --tail=1000 aztec-sequencer"
