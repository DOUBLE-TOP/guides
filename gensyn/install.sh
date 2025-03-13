#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-30 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

mkdir -p /etc/docker
cat <<EOL > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOL

systemctl restart docker

sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
sudo apt install python3 python3-pip -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
# Удаляем неактуальный код с папкой rl-swarm если такая уже есть
dir="rl-swarm"
if [ -d "$dir" ]; then
   rm -rf "$dir"
fi

# Клонируем репозиторий Gensyn-AI
REPO_URL="https://github.com/gensyn-ai/rl-swarm/"
git clone "$REPO_URL"
cd rl-swarm || { echo "Failed to enter directory rl-swarm"; exit 1; }
mv docker-compose.yaml docker-compose.yaml.old
# Create a new docker-compose.yaml file with the specified content
cat <<EOL > docker-compose.yaml
services:
  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.120.0
    container_name: gensyn_otel_collector
    ports:
      - "4317:4317"  # OTLP gRPC
      - "4318:4318"  # OTLP HTTP
      - "55679:55679"  # Prometheus metrics (optional)
    environment:
      - OTEL_LOG_LEVEL=DEBUG

  swarm_node:
    image: europe-docker.pkg.dev/gensyn-public-b7d9/public/rl-swarm:v0.0.1
    container_name: gensyn_swarm_node
    command: ./run_hivemind_docker.sh
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - PEER_MULTI_ADDRS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
      - HOST_MULTI_ADDRS=/ip4/0.0.0.0/tcp/38331
    ports:
      - "38331:38331"
    depends_on:
      - otel-collector

  fastapi:
    container_name: gensyn_fastapi
    build:
      context: .
      dockerfile: Dockerfile.webserver
    environment:
      - OTEL_SERVICE_NAME=rlswarm-fastapi
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - INITIAL_PEERS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
    ports:
      - "4347:8000"
    depends_on:
      - otel-collector
      - swarm_node
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/healthz"]
      interval: 30s
      retries: 3
EOL
echo "docker-compose.yaml создан. Запускаю docker."
docker compose up --build -d

ip=$(hostname -I | awk '{print $1}')
echo "Готово. Статус можно проверить тут: http://$ip:4347"
