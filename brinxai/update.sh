#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

# Находим контейнер worker node и контейнеры запущенных моделей
echo "Находим контейнер worker node и контейнеры запущенных моделей"
brinxai_containers=$(docker ps --format "{{.Names}} {{.Image}}" | grep "brinxai" || true)
# Инициализуем массивы для переподнимания и заполняем коммандами
models_to_start=()
declare -A models_start_commands
models_start_commands["rembg"]="docker run -d --name rembg --network brinxai-network --cpus=2 --memory=2048m -p 127.0.0.1:7000:7000 --restart unless-stopped admier/brinxai_nodes-rembg:latest"
models_start_commands["text-ui"]="docker run -d --name text-ui --network brinxai-network --cpus=4 --memory=4096m -p 127.0.0.1:5000:5000 --restart unless-stopped admier/brinxai_nodes-text-ui:latest"
models_start_commands["stable-diffusion"]="docker run -d --name stable-diffusion --network brinxai-network --cpus=8 --memory=8192m -p 127.0.0.1:5050:5050 --restart unless-stopped admier/brinxai_nodes-stabled:latest"
models_start_commands["upscaler"]="docker run -d --name upscaler --network brinxai-network --cpus=2 --memory=2048m -p 127.0.0.1:3030:3030 --restart unless-stopped admier/brinxai_nodes-upscaler:latest"

# Останавливаем все текущие запущенные контейнеры brinxai
echo "Удаляем контейнеры моделей"
for container in $brinxai_containers; do
  container_name=$(echo $container | awk '{print $1}')

  # Проверяем, существует ли контейнер
  if docker ps -a --format "{{.Names}}" | grep -q "^$container_name$"; then
    # Добавляем контейнер для будущего старта
    models_to_start+=("$container_name")
    # Останавливаем контейнер по имени
    docker rm -f $container_name && echo "Остановлен: $container_name"
  fi
done

# Загружаем последнюю версию Worker Node
echo "Загружаем последнюю версию Worker Node"
docker pull admier/brinxai_nodes-worker:latest

# Запускаем Worker Node
echo "Запускаем Worker Node"
cd $HOME/brinxai_worker
docker compose up -d

# Пройдемся по остановленым нодам и запустим (кроме Воркер ноды - ее мы в models_to_start не прописали, т.к. мы ее только что запустили)
for model in "${models_to_start[@]}"; do
  if [[ -n "${models_start_commands[$model]}" ]]; then
    echo "Стартую модель: $model"
    eval "${models_start_commands[$model]}"
  fi
done

echo "-----------------------------------------------------------------------"
echo -e "Обновление завершено"
echo "-----------------------------------------------------------------------"
echo -e "Обязательно проверьте статус запущенных контейнеров (UP):"
echo -e "docker ps -a | grep brinxai"
echo "-----------------------------------------------------------------------"
echo -e "Команда для проверки логов:"
echo -e "docker logs -f --tail=100 brinxai_worker-worker-1"
echo "------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "------------------------------------------------------------------------"
