#! /bin/bash
#thanks for https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/shardeum/shardeum_healthcheck.sh


function get_status() {
    STATUS=$(docker exec -it shardeum-dashboard operator-cli status | grep status | awk -F': ' '{print $2}')
    echo "${STATUS}"
}


# function start_node() {
#     TOKEN=${1}
#     DASHPORT=${2}
#     curl --location --insecure --request POST "https://${IP_ADDRESS}:${DASHPORT}/api/node/start" \
#     --header 'Content-Type: application/json' \
#     --header "X-Api-Token: ${TOKEN}"
# }

cd "$HOME" || exit
source .profile
# IP_ADDRESS=$(wget -qO- http://ipecho.net/plain | xargs echo)
# DASHPASS=$(cat "$HOME"/.shardeum/.env | grep DASHPASS | cut -d= -f2)
# DASHPORT=$(cat "$HOME"/.shardeum/.env | grep DASHPORT | cut -d= -f2)
while true
do
    printf "Check shardeum node status \n"
    NODE_STATUS=$(get_status)
    printf "Current status: ${NODE_STATUS}\n"
    sleep 5s
    if [ -z "$NODE_STATUS" ]; then
        echo "Shardeum нода не запущена"
        docker start shardeum-dashboard
        sleep 15m
    else
        if [ "$NODE_STATUS" == "standby" ]; then
            echo "Status is standby"
        else
            echo "Status is not standby"
            docker exec -it shardeum-dashboard operator-cli start
        fi
        sleep 15m
    fi
done