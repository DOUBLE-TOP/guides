sudo tee <<EOF >/dev/null $HOME/docker-compose-multi-5.yaml
version: "3.3"
services:
 ironfish1:
  container_name: ironfish1
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish1:/root/.ironfish
 ironfish2:
  container_name: ironfish2
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish2:/root/.ironfish
 ironfish3:
  container_name: ironfish3
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish3:/root/.ironfish
 ironfish4:
  container_name: ironfish4
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish4:/root/.ironfish
 ironfish5:
  container_name: ironfish5
  image: ghcr.io/iron-fish/ironfish:latest
  restart: always
  entrypoint: sh -c "apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
  healthcheck:
   test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
   interval: 180s
   timeout: 180s
   retries: 3
  volumes:
   - $HOME/.ironfish5:/root/.ironfish
EOF

echo "alias ironfish1='docker exec ironfish ./bin/run'" >> ~/.profile
echo "alias ironfish2='docker exec ironfish ./bin/run'" >> ~/.profile
echo "alias ironfish3='docker exec ironfish ./bin/run'" >> ~/.profile
echo "alias ironfish4='docker exec ironfish ./bin/run'" >> ~/.profile
echo "alias ironfish5='docker exec ironfish ./bin/run'" >> ~/.profile

source ~/.profile

echo "Взаимодействие с нодами идет через команды ironfish1-5"
echo "Пример:"
echo "ironfish1 config:set blockGraffiti myname1"
echo "ironfish2 config:set blockGraffiti myname2"
echo "ironfish3 config:set blockGraffiti myname3"
echo "ironfish4 config:set blockGraffiti myname4"
echo "ironfish5 config:set blockGraffiti myname5"
