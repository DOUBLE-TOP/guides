#!/bin/bash
height=$(curl -s http://127.0.0.1:8888/status | jq -r .last_added_block_info.height)
sudo systemctl stop casper-node-launcher
step=20
new_height=$(($height+$step))
sudo sed -i "/trusted_hash =/c\trusted_hash = '$(casper-client get-block --node-address http://94.130.10.55:7777 -b $new_height | jq -r .result.block.hash | tr -d '\n')'" /etc/casper/*/config.toml
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
