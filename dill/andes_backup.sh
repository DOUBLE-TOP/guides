#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

sudo systemctl stop dill

cd $HOME
mkdir -p dill_backups
mkdir -p dill_backups/andes

cp -r $HOME/dill/keystore $HOME/dill_backups/andes/keystore
cp -r $HOME/dill/validator_keys $HOME/dill_backups/andes/validator_keys
cp $HOME/dill/walletPw.txt $HOME/dill_backups/andes/walletPw.txt
cp $HOME/dill/validators.json $HOME/dill_backups/andes/validators.json

sudo systemctl disable dill
sudo systemctl daemon-reload

rm -rf $HOME/dill
rm -f /etc/systemd/system/dill.service

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"