#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
WITHOU_COLOR='\033[0m'

for (( ;; )); do
  for (( timer=30; timer>0; timer-- ))
  do
      printf "* sleep for ${RED_COLOR}%02d${WITHOU_COLOR} sec\r" $timer
      sleep 1
  done
  TEKU_STATUS=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep charon | grep teku | awk '{print $2}')

  echo "Teku status is $TEKU_STATUS"

  case $TEKU_STATUS in
    Up)
    ;;
    *)
    echo "Removing lock file"
    rm $HOME/charon-distributed-validator-node/.charon/validator_keys/keystore-0.json.lock
    ;;
  esac
done

#tmux new-session -d -s obol-teku 'bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/obol/teku_fix.sh)'
