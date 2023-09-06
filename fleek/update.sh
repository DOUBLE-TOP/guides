#!/bin/bash

sudo systemctl stop lgtn

wget -O /usr/local/bin/lgtn https://doubletop-bin.ams3.digitaloceanspaces.com/fleek/testnet-alpha-0/lightning-node

chmod +x /usr/local/bin/lgtn

sudo systemctl restart lgtn