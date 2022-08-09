#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $BUNDLR_ADDR ]; then
	read -p "Введите ваш адрес кошелька (в формате - JunMG4mGXSHN3WR-qiioGsGDn7mhQjlb2d4fCUQYfjg): " BUNDLR_ADDR
fi
echo 'Ваше имя ноды: ' $BUNDLR_ADDR
sleep 1
BUNDLR_PORT=2109
echo "export BUNDLR_PORT="${BUNDLR_PORT}"" >> $HOME/.profile
echo 'export BUNDLR_ADDR='$BUNDLR_ADDR >> $HOME/.profile
echo "Ваш кошелек добавлен в систему в виде переменной"
echo "-----------------------------------------------------------------------------"
