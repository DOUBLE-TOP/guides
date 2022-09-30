#!/bin/bash

tmux kill-session -t tfsc

#cd $HOME
#if [ ! -d $HOME/tfsc_backup/ ]; then
#  mkdir -p $HOME/tfsc_backup
#  cp $HOME/tfsc/cert/* $HOME/tfsc_backup/
#fi

rm -rf $HOME/tfsc
mkdir $HOME/tfsc

cd $HOME/tfsc/
wget -O $HOME/tfsc/tfsc  https://uscloudmedia.s3.us-west-2.amazonaws.com/transformers/test/ttfs_v0.8.0_76a6414_devnet

cd $HOME/tfsc/
PUB_IP=$(wget -qO- eth0.me);wget -qO- pastebin.com/raw/MfS126mf|sed 's#\"ip\": \"pub_ip\"#\"ip\": '\"${PUB_IP}\"'#' > config.json
sed -i "s/OFF/INFO/" "$HOME/tfsc/config.json"

chmod +x $HOME/tfsc/tfsc

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
