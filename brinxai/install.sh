#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-10 min.)"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

# Removing old installation if exists
echo "Удаляем старую версию brinx.ai (если уже стоит)"
docker rm -f brinxai_worker-worker-1 text-ui stable-diffusion rembg upscaler brinxai_relay 2>/dev/null || true
docker ps -a -q --filter "name=brinxai_worker" | xargs -r docker rm -f > /dev/null 2>&1
docker ps -a -q --filter ancestor=admier/brinxai_nodes-worker | xargs -r docker rm -f && docker rmi admier/brinxai_nodes-worker
#docker image inspect admier/brinxai_nodes-worker >/dev/null 2>&1 && docker rmi admier/brinxai_nodes-worker
docker volume prune -f
docker network prune -f
rm -rf $HOME/brinxai_worker
# removal end

# Function to validate UUID format
validate_uuid() {
    local uuid=$1
    if [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Update package list and install dependencies
sudo apt-get install -y gnupg lsb-release &>/dev/null

# Check if GPU is available
echo "Проверяем есть ли GPU"
GPU_AVAILABLE=false
if command -v nvidia-smi &> /dev/null; then
    echo "GPU найден. Ставим NVIDIA драйвер."
    GPU_AVAILABLE=true
else
    echo "GPU не найден."
fi

# Prompt user for WORKER_PORT
read -p "Введите порт для воркера (Enter - по умолчанию 5011): " USER_PORT
USER_PORT=${USER_PORT:-5011}

# Prompt user for node_UUID
while true; do
    read -p "Введите UUID ноды (например 123e4567-e89b-12d3-a456-426614174000): " NODE_UUID
    if validate_uuid "$NODE_UUID"; then
        echo "UUID принят."
        break
    else
        echo "Неверный формат UUID. Введите UUID (например 123e4567-e89b-12d3-a456-426614174000)."
    fi
done

mkdir -p $HOME/brinxai_worker
cd $HOME/brinxai_worker

echo "Создаем .env файл"
cat <<EOF > .env
WORKER_PORT=$USER_PORT
NODE_UUID=$NODE_UUID
USE_GPU=$GPU_AVAILABLE
CUDA_VISIBLE_DEVICES=""
EOF

# Create docker-compose.yml file
echo "Создаем docker-compose.yml"
if [ "$GPU_AVAILABLE" = true ]; then
    cat <<EOF > docker-compose.yml
services:
  brinxai_worker:
    image: admier/brinxai_nodes-worker:latest
    restart: unless-stopped
    environment:
      - WORKER_PORT=\${WORKER_PORT:-5011}
      - NODE_UUID=\${NODE_UUID}
      - USE_GPU=\${USE_GPU:-true}
      - CUDA_VISIBLE_DEVICES=\${CUDA_VISIBLE_DEVICES}
    ports:
      - "\${WORKER_PORT:-5011}:\${WORKER_PORT:-5011}"
    volumes:
      - ./generated_images:/usr/src/app/generated_images
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - brinxai-network
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
    runtime: nvidia

networks:
  brinxai-network:
    driver: bridge
    name: brinxai-network
EOF
else
    cat <<EOF > docker-compose.yml
services:
  brinxai_worker:
    image: admier/brinxai_nodes-worker:latest
    restart: unless-stopped
    environment:
      - WORKER_PORT=\${WORKER_PORT:-5011}
      - NODE_UUID=\${NODE_UUID}
      - USE_GPU=\${USE_GPU:-false}
      - CUDA_VISIBLE_DEVICES=\${CUDA_VISIBLE_DEVICES}
    ports:
      - "\${WORKER_PORT:-5011}:\${WORKER_PORT:-5011}"
    volumes:
      - ./generated_images:/usr/src/app/generated_images
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - brinxai-network

networks:
  brinxai-network:
    driver: bridge
    name: brinxai-network
EOF
fi

docker compose down --remove-orphans

echo "Скачиваем последнюю версию контейнера BrixAI"
docker pull admier/brinxai_nodes-worker:latest

echo "Запускаем Docker контейнеры"
docker compose up -d

echo "Проверяем статус контейнеров:"
sleep 5 # Wait for container to stabilize
docker ps -a --filter "name=brinxai_worker"


echo ""
echo "Установка завершена"
echo "Проверка логов: "
echo 'docker logs $(docker ps -a -q --filter "name=brinxai_worker")'
