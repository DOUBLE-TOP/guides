 #!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/autonomys\/node:gemini-3h-2024-sep-17/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/autonomys\/farmer:gemini-3h-2024-sep-17/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/--state-pruning", "archive-canonical"/--state-pruning", "140000"/g' $HOME/subspace_docker*/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3h-2024-sep-17
docker rmi -f ghcr.io/subspace/farmer:gemini-3h-2024-sep-17
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout 3727d07430d323b5616a3908a2f87762f6acf6fc

docker build -t ghcr.io/subspace/node:gemini-3h-2024-sep-17 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3h-2024-sep-17 -f Dockerfile-farmer .

docker-compose -f $FILE up -d
