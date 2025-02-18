#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление ноды"
echo "-----------------------------------------------------------------------------"

sudo systemctl stop pop

sudo wget -O $HOME/opt/dcdn/pop "https://dl.pipecdn.app/v0.2.6/pop"

chmod +x $HOME/opt/dcdn/pop
sudo ln -s $HOME/opt/dcdn/pop /usr/local/bin/pop -f

cd $HOME/opt/dcdn && ./pop --refresh

sudo systemctl start pop

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u pop -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
