#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

# Скачиваем image из Docker Hub
docker pull admier/brinxai_nodes-worker:latest

# Копируем репозиторий и заходим в директорию
git clone https://github.com/admier1/BrinxAI-Worker-Nodes
mv BrinxAI-Worker-Nodes brinxai_worker
cd brinxai_worker

# Создаем .env файл
echo "Creating .env file"
cat <<EOF > .env
WORKER_PORT=5011
EOF

# Создаём docker-compose.yml
echo "Создаём docker-compose.yml"
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  worker:
    image: admier/brinxai_nodes-worker:latest
    environment:
      - WORKER_PORT=\${WORKER_PORT:-5011}
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
    name: brinxai-network  # Явно задаем имя сети
EOF

# Запускаем контейнер
echo "Запускаем Docker контейнер"
docker compose up -d

echo "-----------------------------------------------------------------------"
echo -e "Команда для проверки логов:"
echo -e "docker logs -f --tail=100 brinxai_worker-worker-1"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"