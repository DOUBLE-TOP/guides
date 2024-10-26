#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление сервисного файла"
echo "-----------------------------------------------------------------------------"

sudo systemctl stop hemi

sed -i "s|FEE=*|FEE=4000|" /etc/systemd/system/hemi.service

sudo systemctl daemon-reload
sudo systemctl start hemi

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
