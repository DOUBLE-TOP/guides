 #!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/subspace\/node:gemini-3g-2024-jan-08/g' $HOME/subspace_docker/docker-compose.yml
    sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/subspace\/farmer:gemini-3g-2024-jan-08/g' $HOME/subspace_docker/docker-compose.yml
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi

docker-compose -f $FILE down

docker rmi -f ghcr.io/subspace/node:gemini-3g-2024-jan-24   
docker rmi -f ghcr.io/subspace/farmer:gemini-3g-2024-jan-24
docker image prune -a -f

cd $HOME
rm -rf $HOME/subspace
git clone https://github.com/subspace/subspace
cd $HOME/subspace
git checkout b3dac2c718f83e7c4bdf46b7107f43205e05d9cd

docker build -t ghcr.io/subspace/node:gemini-3g-2024-jan-08 -f Dockerfile-node .
docker build -t ghcr.io/subspace/farmer:gemini-3g-2024-jan-08 -f Dockerfile-farmer .

docker-compose -f $FILE up -d 

# docker tag ghcr.io/subspace/node:gemini-3g-2024-jan-08 razumv95/node:gemini-3g-2024-jan-08
# docker tag ghcr.io/subspace/farmer:gemini-3g-2024-jan-08 razumv95/farmer:gemini-3g-2024-jan-08
# docker pull razumv95/node:gemini-3g-2024-jan-08 && docker pull razumv95/farmer:gemini-3g-2024-jan-08 && docker rmi -f ghcr.io/subspace/node:gemini-3g-2024-jan-08 && docker rmi -f ghcr.io/subspace/farmer:gemini-3g-2024-jan-08 && docker tag razumv95/node:gemini-3g-2024-jan-08 ghcr.io/subspace/node:gemini-3g-2024-jan-08 && docker tag razumv95/farmer:gemini-3g-2024-jan-08 ghcr.io/subspace/farmer:gemini-3g-2024-jan-08 && docker-compose -f /home/user/subspace_docker/docker-compose.yml up -d 
