#!/bin/bash

source $HOME/.profile

sudo apt-get install wget lz4 aria2 pv -y
sudo systemctl stop 0g
cp $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup
0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book

cd $HOME
rm -f 0gchain_snapshot.lz4

if curl -s --head https://vps4.josephtran.xyz/0g/0gchain_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
  echo "Snapshot found, downloading..."
  aria2c -x 16 -s 16 https://vps4.josephtran.xyz/0g/0gchain_snapshot.lz4 -o 0gchain_snapshot.lz4
  if [ $? -eq 0 ]; then
    echo "Download complete, extracting..."
    lz4 -dc 0gchain_snapshot.lz4 | tar -xf - -C $HOME/.0gchain
    if [ $? -eq 0 ]; then
      echo "Snapshot downloaded and extracted successfully."
    else
      echo "Failed to extract snapshot."
    fi
  else
    echo "Failed to download snapshot."
  fi
else
  echo "No snapshot found."
fi

mv $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json
sudo systemctl restart 0g

cd $HOME
rm 0gchain_snapshot.lz4