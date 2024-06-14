#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Сохранение данных с ноды Nubit"
echo "-----------------------------------------------------------------------------"

rm -rf .nubit-light-nubit-alphatestnet-1
if [ ! -f $HOME/nubit-node/mnemonic.txt ]; then
    echo "Cначала создайте mnemonic.txt и положите его в папку $HOME/nubit-node"
    exit 1
fi

echo "-----------------------------------------------------------------------------"
echo "Удаление старых данных с ноды Nubit"
echo "-----------------------------------------------------------------------------"

cd $HOME/nubit-node
rm -rf Dockerfile

docker rm -f nubit
docker images | grep "nubit" | awk '{print $3}' | xargs docker rmi -f

echo "-----------------------------------------------------------------------------"
echo "Обновление ноды Nubit"
echo "-----------------------------------------------------------------------------"

wget -O Dockerfile https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/nubit/Dockerfile.update
docker build --no-cache -t nubit_image . && docker run -d --name nubit --restart always nubit_image

sleep 30

docker exec -it nubit ./expect.sh
docker restart nubit

sleep 30

echo "-----------------------------------------------------------------------------"
echo "PUBLIC KEY"
docker exec -it nubit /home/nubit-user/nubit-node/bin/nkey list --p2p.network nubit-alphatestnet-1 --node.type light | grep -oP '(?<="key":")[^"]*'
echo "-----------------------------------------------------------------------------"
echo "Light Nubit Node успешно обновлена"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов:"
echo "docker logs -f --tail=100 nubit"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"