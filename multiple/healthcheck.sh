#!/bin/bash

read -p "Enter IDENTIFIER: " IDENTIFIER
read -p "Enter PIN: " PIN
echo ""



# Run the tmux command with the provided IDENTIFIER and PIN
tmux new-session -d -s multiple_healthcheck "bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/multiple/health.sh) $IDENTIFIER $PIN"
echo "Multiple Health Check started (tmux session multiple_healthcheck)"
