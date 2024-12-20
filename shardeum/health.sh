#! /bin/bash
#thanks for https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/shardeum/shardeum_healthcheck.sh


function get_node_status() {
    STATUS=$(docker exec -it shardeum-validator operator-cli status | grep state | awk -F': ' '{print $2}')
    echo "${STATUS}"
}

function get_gui_status() {
    STATUS=$(docker exec -it shardeum-validator operator-cli gui status | grep status | awk -F': ' '{print $2}')
    echo "${STATUS}"
}

cd "$HOME" || exit

while true
do
    printf "Check shardeum node status \n"
    NODE_STATUS=$(get_node_status)
    GUI_STATUS=$(get_gui_status)
    printf "Current node status: ${NODE_STATUS}\n"
    printf "Current dashboard status: ${GUI_STATUS}\n"

    sleep 5s
    if [ -z "$NODE_STATUS" ]; then
        echo "Shardeum нода не запущена"
        docker start shardeum-validator
        sleep 5m
    else
        if [[ "${NODE_STATUS}" == *"stopped"* ]]; then
            echo "Node status is stopped"
            docker exec -it shardeum-validator operator-cli start
        else
            echo "Node status is $NODE_STATUS"
        fi
    fi

    if [[ "${GUI_STATUS}" == *"online"* ]]; then
        echo "Dashboard status is online"
    else
        echo "Dashboard status is $GUI_STATUS"
        docker exec -it shardeum-validator operator-cli gui start
    fi

    sleep 15m
done