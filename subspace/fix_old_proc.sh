#!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/subspace\/node:gemini-3g-2023-dec-20/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/subspace\/farmer:gemini-3g-2023-dec-20/g' $HOME/subspace_docker/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3g-2023-dec-20   
docker rmi -f ghcr.io/subspace/farmer:gemini-3g-2023-dec-20
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout 1b8b5f310685a9cc0ef8192042257435ace285af

docker build -t ghcr.io/subspace/node:gemini-3g-2023-dec-20 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3g-2023-dec-20 -f Dockerfile-farmer .

docker-compose -f $FILE up -d 