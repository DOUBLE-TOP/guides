#!/bin/bash

docker-compose -f $HOME/nwaku-compose/docker-compose.yml down

cd $HOME/nwaku-compose/
# убираем изменения в docker-compose для коректного git pull
git checkout -- docker-compose.yml
git pull

# Меняем назад docker-compose.yml
sed -i '/^version: "3.7"$/d' $HOME/nwaku-compose/docker-compose.yml
sed -i 's/0\.0\.0\.0:3000:3000/0.0.0.0:3004:3000/g' $HOME/nwaku-compose/docker-compose.yml
sed -i 's/127\.0\.0\.1:4000:4000/0.0.0.0:4044:4000/g' $HOME/nwaku-compose/docker-compose.yml
sed -i 's|127.0.0.1:8003:8003|127.0.0.1:8333:8003|' $HOME/nwaku-compose/docker-compose.yml
sed -i 's/:5432:5432/:5444:5432/g' $HOME/nwaku-compose/docker-compose.yml
sed -i 's/80:80/8081:80/g' $HOME/nwaku-compose/docker-compose.yml

docker compose -f $HOME/nwaku-compose/docker-compose.yml up -d

echo "Готово."
