#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Выполняем фикс"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh
ufw deny in 19002
ufw deny in 19122
ufw deny in 19005
echo "-----------------------------------------------------------------------------"
echo "Теперь ваша нода под защитой ufw ❤️ "
echo "-----------------------------------------------------------------------------"
