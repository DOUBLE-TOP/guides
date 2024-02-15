 #!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/subspace\/node:gemini-3h-2024-feb-15/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/subspace\/farmer:gemini-3h-2024-feb-15/g' $HOME/subspace_docker/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3h-2024-feb-15
docker rmi -f ghcr.io/subspace/farmer:gemini-3h-2024-feb-15
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout ad2cc2c740a657b653d2e9800c314f2e6a64e746

docker build -t ghcr.io/subspace/node:gemini-3h-2024-feb-15 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3h-2024-feb-15 -f Dockerfile-farmer .

docker-compose -f $FILE up -d