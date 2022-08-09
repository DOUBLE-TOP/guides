#!/bin/bash

pkill -9 tfsc

rm -rf $HOME/tfsc/tfsc
rm -rf $HOME/tfsc/config.json
rm -rf $HOME/tfsc/data.db

cd $HOME/tfsc/
wget -O $HOME/tfsc/tfsc https://fastcdn.uscloudmedia.com/transformers/test/ttfsc_v0.1.3_6a8a76e_devnet

cd $HOME/tfsc/
PUB_IP=$(wget -qO- eth0.me);wget -qO- pastebin.com/raw/MfS126mf|sed 's#\"ip\": \"172.17.0.1\"#\"ip\": '\"${PUB_IP}\"'#' > config.json

chmod +x $HOME/tfsc/tfsc

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
