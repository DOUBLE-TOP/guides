 #!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/autonomys\/node:gemini-3h-2024-jul-26/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/autonomys\/farmer:gemini-3h-2024-jul-26/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/--state-pruning", "archive-canonical"/--state-pruning", "140000"/g' $HOME/subspace_docker*/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3h-2024-jul-26
docker rmi -f ghcr.io/subspace/farmer:gemini-3h-2024-jul-26
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout 0a89bdbeb480ae4446d38b3c06c720f9021858f6

docker build -t ghcr.io/subspace/node:gemini-3h-2024-jul-26 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3h-2024-jul-26 -f Dockerfile-farmer .

docker-compose -f $FILE up -d
