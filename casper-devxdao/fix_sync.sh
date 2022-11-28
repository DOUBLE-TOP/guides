#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=fa5f19d9c61d17a04550e5b0efad2cdd78599948afd886a68ec11af176c688a9
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
