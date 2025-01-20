#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление майнера Hemi Network"
echo "-----------------------------------------------------------------------------"

grep -qxF 'fs.inotify.max_user_watches=524288' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

systemctl stop hemi

cd $HOME

wget https://github.com/hemilabs/heminetwork/releases/download/v0.11.1/heminetwork_v0.11.1_linux_amd64.tar.gz

tar -xvf heminetwork_v0.11.1_linux_amd64.tar.gz && rm heminetwork_v0.11.1_linux_amd64.tar.gz
mv -f $HOME/heminetwork_v0.11.1_linux_amd64/* $HOME/heminetwork
rm -rf $HOME/heminetwork_v0.11.1_linux_amd64

sudo systemctl daemon-reload
sudo systemctl start hemi

echo "-----------------------------------------------------------------------------"
echo "Hemi Network успешно установлен"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
