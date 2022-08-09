#!/bin/bash

cd $HOME/snarkOS
git checkout -- Cargo.lock
# while :
# do
  echo "Checking for updates..."
  STATUS=$(git pull)

  echo $STATUS

  if [ "$STATUS" != "Already up to date." ]; then
	source $HOME/.cargo/env
	cargo clean
	cargo build --release
	# cargo clean
	if [[ `service miner status | grep active` =~ "running" ]]; then
	  echo "Aleo Miner is active"
	  systemctl stop miner
	  ALEO_IS_MINER=true
	fi
	if [[ `echo $ALEO_IS_MINER` =~ "true" ]]; then
	  echo "Aleo Miner restarted"
	  systemctl restart miner
	fi
  fi
# done
