#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление ноды"
echo "-----------------------------------------------------------------------------"

cd /opt/popcache || { echo "Директория /opt/popcache не найдена"; exit 1; }

echo "Остановка сервиса popcache"
systemctl stop popcache.service

echo "Загрузка новой версии"
wget https://download.pipe.network/static/pop-v0.3.2-linux-x64.tar.gz &>/dev/null || { echo "Произошла ошибка загрузки архива"; exit 1; }

echo "Удаляем старый бинарник, распаковываем архив"
rm -f pop
tar -xvzf pop-v0.3.2-linux-x64.tar.gz &>/dev/null
rm -f pop-v0.3.2-linux-x64.tar.gz
chmod +x pop

echo "Запуск сервиса popcache"
systemctl start popcache.service

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "tail -f /opt/popcache/logs/stdout.log"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
