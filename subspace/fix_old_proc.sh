 #!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/autonomys\/node:gemini-3h-2024-oct-03/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/autonomys\/farmer:gemini-3h-2024-oct-03/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/--state-pruning", "archive-canonical"/--state-pruning", "140000"/g' $HOME/subspace_docker*/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3h-2024-oct-03
docker rmi -f ghcr.io/subspace/farmer:gemini-3h-2024-oct-03
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout b0e738e7d55a69f40069a9415de49f9a0fc1f67e

docker build -t ghcr.io/subspace/node:gemini-3h-2024-oct-03 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3h-2024-oct-03 -f Dockerfile-farmer .

docker-compose -f $FILE up -d
