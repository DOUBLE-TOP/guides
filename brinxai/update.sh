#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

# Находим контейнер worker node и контейнеры запущенных моделей
echo "Находим контейнер worker node и контейнеры запущенных моделей"
brinxai_containers=$(docker ps --format "{{.Names}} {{.Image}}" | grep "brinxai" || true)

# Останавливаем все текущие запущенные контейнеры brinxai
echo "Удаляем контейнеры моделей"
for container in $brinxai_containers; do
  container_name=$(echo $container | awk '{print $1}')
  
  # Проверяем, существует ли контейнер
  if docker ps -a --format "{{.Names}}" | grep -q "^$container_name$"; then
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

# Выводим список моделей, которые были запущены до обновления
echo "Следующие модели были активны до обновления. Вы можете запустить их вручную:"
echo "$brinxai_containers"

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