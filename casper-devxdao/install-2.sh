#!/bin/bash
CASPER_VERSION=1_0_0
CASPER_NETWORK=casper-test
cd ~
sudo cp $HOME/casper-node/target/wasm32-unknown-unknown/release/add_bid.wasm /opt
sudo chown casper.casper /opt/add_bid.wasm

sudo -u casper /etc/casper/pull_casper_node_version.sh $CASPER_NETWORK.conf $CASPER_VERSION
sudo -u casper /etc/casper/config_from_example.sh $CASPER_VERSION

KNOWN_ADDRESSES=$(sudo -u casper cat /etc/casper/$CASPER_VERSION/config.toml | grep known_addresses)
KNOWN_VALIDATOR_IPS=$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$KNOWN_ADDRESSES")
IFS=' ' read -r KNOWN_VALIDATOR_IP _REST <<< "$KNOWN_VALIDATOR_IPS"

echo $KNOWN_VALIDATOR_IP

TRUSTED_HASH=$(curl -s 94.130.10.55:8888/status | jq -r .last_added_block_info.hash | tr -d '\n')
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/$CASPER_VERSION/config.toml; fi

sudo -u casper /etc/casper/node_util.py stage_protocols casper-test.conf

sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher; sleep 2
systemctl status casper-node-launcher

echo "##########################################"
echo "Installation finished"
echo "Bond to the network"
echo "##########################################"
