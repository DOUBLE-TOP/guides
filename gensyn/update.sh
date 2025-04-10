#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
sudo systemctl stop gensyn.service
cd $HOME/rl-swarm
git pull --rebase
sudo systemctl start gensyn.service
echo "Обновлено успешно"
