#! /bin/bash
#thanks for https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/shardeum/shardeum_healthcheck.sh


function get_status() {
    STATUS=$(docker exec -it shardeum-dashboard operator-cli status | grep status | awk -F': ' '{print $2}')
    echo "${STATUS}"
}

cd "$HOME" || exit

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
        if [[ "${NODE_STATUS}" == *"standby"* ]]; then
            echo "Status is standby"
        else
            echo "Status is not standby"
            docker exec -it shardeum-dashboard operator-cli start
        fi
        sleep 15m
    fi
done