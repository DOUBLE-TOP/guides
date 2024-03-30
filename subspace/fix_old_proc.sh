 #!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/subspace\/node:gemini-3h-2024-mar-28/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/subspace\/farmer:gemini-3h-2024-mar-28/g' $HOME/subspace_docker/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3h-2024-mar-28
docker rmi -f ghcr.io/subspace/farmer:gemini-3h-2024-mar-28
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout 8d18af2734183e018b57dcf001611d7fcc074b81

docker build -t ghcr.io/subspace/node:gemini-3h-2024-mar-28 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3h-2024-mar-28 -f Dockerfile-farmer .

docker-compose -f $FILE up -d
