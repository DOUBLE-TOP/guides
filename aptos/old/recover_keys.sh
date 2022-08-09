#!/bin/bash

function get_vars {
  PEER_ID=$(sed -n 2p $HOME/aptos/identity/peer-info.yaml | sed 's/.$//' | sed 's/://g')
  PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
  WAYPOINT=$(cat $HOME/aptos/waypoint.txt)
}

function fix_config {
  wget -O $HOME/aptos/seeds.yaml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aptos/seeds.yaml
  wget -O $HOME/aptos/public_full_node.yaml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aptos/public_full_node.yaml
  sed -i '/network_id: "public"$/a\
      identity:\
        type: "from_config"\
        key: "'$PRIVATE_KEY'"\
        peer_id: "'$PEER_ID'"' $HOME/aptos/public_full_node.yaml

  /usr/local/bin/yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml $HOME/aptos/seeds.yaml

  sed -i 's|127.0.0.1|0.0.0.0|' $HOME/aptos/public_full_node.yaml
  sed -i -e "s|genesis_file_location: .*|genesis_file_location: \"$HOME\/aptos\/genesis.blob\"|" $HOME/aptos/public_full_node.yaml
  sed -i -e "s|data_dir: .*|data_dir: \"$HOME\/aptos\/data\"|" $HOME/aptos/public_full_node.yaml
  sed -i -e "s|0:01234567890ABCDEFFEDCA098765421001234567890ABCDEFFEDCA0987654210|$WAYPOINT|" $HOME/aptos/public_full_node.yaml
}



sudo systemctl stop aptos
get_vars
fix_config
sudo systemctl start aptos
