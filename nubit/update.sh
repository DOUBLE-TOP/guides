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

echo "-----------------------------------------------------------------------------"
echo "Light Nubit Node успешно обновлена"
echo "-----------------------------------------------------------------------------"
echo "Mnemonic"
echo "cat $HOME/nubit-node/mnemonic.txt"
echo "-----------------------------------------------------------------------------"
echo "Backup Keys from folder"
echo "$HOME/nubit-node/keys"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов:"
echo "docker logs -f --tail=100 nubit"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"