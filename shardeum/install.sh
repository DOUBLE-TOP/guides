#!/usr/bin/env bash

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)

if [ -d "$NODEHOME" ]; then
  if [ "$NODEHOME" != "$(pwd)" ]; then
    echo "Removing existing directory $NODEHOME..."
    rm -rf "$NODEHOME"
  else
    echo "Cannot delete current working directory. Please move to another directory and try again."
  fi
fi

git clone https://gitlab.com/shardeum/validator/dashboard.git ${NODEHOME} && cd ${NODEHOME} && chmod a+x ./*.sh

APPSEEDLIST="archiver-sphinx.shardeum.org"
APPMONITOR="monitor-sphinx.shardeum.org"
SERVERIP=$(curl -s https://api.ipify.org)
LOCALLANIP=$(curl -s https://api.ipify.org)

cd ${NODEHOME}
touch ./.env
cat >./.env <<EOL
APP_IP=auto
EXISTING_ARCHIVERS=[{"ip":"18.194.3.6","port":4000,"publicKey":"758b1c119412298802cd28dbfa394cdfeecc4074492d60844cc192d632d84de3"},{"ip":"139.144.19.178","port":4000,"publicKey":"840e7b59a95d3c5f5044f4bc62ab9fa94bc107d391001141410983502e3cde63"},{"ip":"139.144.43.47","port":4000,"publicKey":"7af699dd711074eb96a8d1103e32b589e511613ebb0c6a789a9e8791b2b05f34"},{"ip":"72.14.178.106","port":4000,"publicKey":"2db7c949632d26b87d7e7a5a4ad41c306f63ee972655121a37c5e4f52b00a542"}]
APP_MONITOR=${APPMONITOR}
DASHPASS=${DASHPASS}
DASHPORT=${DASHPORT}
SERVERIP=${SERVERIP}
LOCALLANIP=${LOCALLANIP}
SHMEXT=${SHMEXT}
SHMINT=${SHMINT}
EOL

docker-compose down -v
docker rmi -f test-dashboard registry.gitlab.com/shardeum/server local-dashboard


docker build --no-cache -t local-dashboard -f Dockerfile --build-arg RUNDASHBOARD=${RUNDASHBOARD} .


sed "s/- '8080:8080'/- '$DASHPORT:$DASHPORT'/" docker-compose.tmpl > docker-compose.yml
sed -i "s/- '9001-9010:9001-9010'/- '$SHMEXT:$SHMEXT'/" docker-compose.yml
sed -i "s/- '10001-10010:10001-10010'/- '$SHMINT:$SHMINT'/" docker-compose.yml
docker-compose up -d

echo "Starting image. This could take a while..."
(docker logs -f shardeum-dashboard &) | grep -q 'done'

# docker exec -it shardeum-dashboard operator-cli gui set password $DASHPASS