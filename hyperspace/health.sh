#!/bin/bash

while true
do
    printf "Check hyperspace logs \n"
    
    logs=$(journalctl -n 10 -u aios)

    # Search the logs for the specific pattern and save the result
    search_result=$(echo "$logs" | grep "Last pong received.*Sending reconnect signal..")

    # Use the search result in an if statement
    if [ -n "$search_result" ]; then
        echo "The node is not connected. Restarting the application!"
        # Restart the application service
        systemctl restart aios
    else
        echo "The pattern for restart was not found. Everything seems fine."
    fi

    sleep 15m
done