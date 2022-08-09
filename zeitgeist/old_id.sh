#!/bin/bash
mkdir -p $HOME/old/
wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.1.1/zeitgeist -O $HOME/old/zeitgeist
chmod +x $HOME/old/zeitgeist
$HOME/old/zeitgeist --node-key-file /root/.local/share/zeitgeist/chains/battery_park/network/secret_ed25519 2>&1 | grep identity 
