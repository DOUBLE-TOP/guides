#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Сохранение данных с ноды Nubit"
echo "-----------------------------------------------------------------------------"

docker cp nubit:/home/nubit-user/.nubit-light-nubit-alphatestnet-1 $HOME/nubit-node

echo "-----------------------------------------------------------------------------"
echo "Удаление старых данных с ноды Nubit"
echo "-----------------------------------------------------------------------------"

cd $HOME/nubit-node
rm -rf Dockerfile

docker rm -f nubit
docker images | grep "nubit" | awk '{print $3}' | xargs docker rmi -f
docker system prune -af

echo "-----------------------------------------------------------------------------"
echo "Обновление ноды Nubit"
echo "-----------------------------------------------------------------------------"

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/nubit/Dockerfile
docker build -t nubit_image . && docker run -d --name nubit nubit_image
rm -rf .nubit-light-nubit-alphatestnet-1

docker logs nubit