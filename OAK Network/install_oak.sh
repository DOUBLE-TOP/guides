#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $OAK_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " OAK_NODENAME
fi
sleep 1
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null
# curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "-----------------------------------------------------------------------------"
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
mkdir /oak-testnet/data
docker pull oaknetwork/oak_testnet:latest & docker run -d --name oak -v ~/oak-testnet/data:/app/data -p 30333:30333 oaknetwork/oak_testnet:latest  --name $OAK_NODENAME --validator bash &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Validator Node $OAK_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
