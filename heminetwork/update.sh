#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление майнера Hemi Network"
echo "-----------------------------------------------------------------------------"

systemctl stop hemi

cd $HOME

wget https://github.com/hemilabs/heminetwork/releases/download/v0.9.0/heminetwork_v0.9.0_linux_amd64.tar.gz

tar -xvf heminetwork_v0.9.0_linux_amd64.tar.gz && rm heminetwork_v0.9.0_linux_amd64.tar.gz
mv -f $HOME/heminetwork_v0.9.0_linux_amd64/* $HOME/heminetwork
rm -rf $HOME/heminetwork_v0.9.0_linux_amd64

sudo systemctl daemon-reload
sudo systemctl start hemi

echo "-----------------------------------------------------------------------------"
echo "Hemi Network успешно установлен"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
