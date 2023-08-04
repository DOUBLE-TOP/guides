#!/usr/bin/env bash

if [[ -z $1 ]]; then
  echo "Usage: $0 <epoch>"
  echo "Waits until the specified epoch, then waits for a new snapshot and halts the validator."
  exit 0
fi

epoch_to_halt=$1

while :
do
  current_epoch=$(solana epoch --commitment finalized -ul)
  echo "Waiting until epoch $epoch_to_halt. Current Epoch: $current_epoch"
  if [[ $current_epoch = $epoch_to_halt ]]; then
    echo "$current_epoch is same as $epoch_to_halt. Initiating shutdown procedure."
    break
  elif [[ $current_epoch -gt $epoch_to_halt ]]; then
    echo "Current epoch $current_epoch is greater than epoch to halt $epoch_to_halt. Bailing out."
    exit 1
  fi

  sleep 600 # poll every 10 minutes
done

# TODO Replace this with a command that will halt your validator
sudo systemctl stop solana