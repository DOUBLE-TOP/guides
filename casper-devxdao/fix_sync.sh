#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=5f3e87adbfaefceb93a39399addad6923173cdd9fefdadc342e3aadac32f6f1d
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
