#thanks for https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/shardeum/shardeum_healthcheck.sh

#! /bin/bash

function login() {
    DASHPORT=${1}
    DASHPASS=${2}
    TOKEN=$(curl --location --insecure --request POST "https://${IP_ADDRESS}:${DASHPORT}/auth/login" \
    --header "Content-Type: application/json" \
    --data-raw '{"password": "'"${DASHPASS}"'"}')
    access_token=$(echo "${TOKEN}" | jq -r '.accessToken')
    echo "${access_token}"
}


function get_status() {
    STATUS=$(docker exec -t shardeum-dashboard operator-cli status | grep state | awk '{ print $2 }')
    echo "${STATUS}"
}


function start_node() {
    TOKEN=${1}
    DASHPORT=${2}
    curl --location --insecure --request POST "https://${IP_ADDRESS}:${DASHPORT}/api/node/start" \
    --header 'Content-Type: application/json' \
    --header "X-Api-Token: ${TOKEN}"
}

cd "$HOME" || exit
source .profile
IP_ADDRESS=$(wget -qO- http://ipecho.net/plain | xargs echo)
DASHPASS=$(cat "$HOME"/.shardeum/.env | grep DASHPASS | cut -d= -f2)
DASHPORT=$(cat "$HOME"/.shardeum/.env | grep DASHPORT | cut -d= -f2)
while true
do
    printf "Check shardeum node status \n"
    NODE_STATUS=$(get_status)
    printf "Current status: ${NODE_STATUS}\n"
    sleep 5s
    if [[ "${NODE_STATUS}" =~ "stopped" ]]; then
        printf "Start shardeum node and wait 5 minutes\n"
        JWT_TOKEN=$(login "${DASHPORT}" "${DASHPASS}")
        start_node "${JWT_TOKEN}" "${DASHPORT}"
        sleep 5m
    else
        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 15 minutes\n"
        sleep 15m
    fi
done