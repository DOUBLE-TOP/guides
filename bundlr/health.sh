#!/bin/bash

function restart_bundlr() {
    echo -e "Restart bundlr ...................................\n"
    docker-compose -f $HOME/bundlr/validator-rust/docker-compose.yml restart
}

cd $HOME
while true
do
        echo -e "Check bundlr validator logs \n"
        if [ $(docker logs --tail=20 validator 2>&1 | grep -c "Connection reset by peer") -gt 0 ]; then
            restart_bundlr
        elif [ $(docker logs --tail=20 validator 2>&1 | grep -c "Invalid HTTP version specified") -gt 0 ]; then
            restart_bundlr
        elif [ $(docker logs --tail=20 validator 2>&1 | grep -c "Invalid Header provided") -gt 0 ]; then
            restart_bundlr
	    fi

        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 1 hour\n"
        sleep 1h
done
