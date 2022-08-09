#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $LUKSO_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " LUKSO_NODENAME
fi
sleep 1
echo 'export LUKSO_NODENAME='$LUKSO_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем "
echo "-----------------------------------------------------------------------------"
curl -s https://install.l15.lukso.network | bash &>/dev/null
lukso start --node-name "$LUKSO_NODENAME" | bash &>/dev/null
echo "Установка завершена"
echo "-----------------------------------------------------------------------------"
