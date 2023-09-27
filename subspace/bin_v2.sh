#!/bin/bash

rm -f /usr/local/bin/pulsar
wget -O pulsar https://github.com/subspace/pulsar/releases/download/v0.6.10-alpha/pulsar-ubuntu-x86_64-v2-v0.6.10-alpha
sudo chmod +x pulsar
sudo mv pulsar /usr/local/bin/
sudo systemctl restart subspace