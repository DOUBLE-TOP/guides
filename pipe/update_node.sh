#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

SERVICE_FILE=/etc/systemd/system/pop.service
exec_line=$(grep '^ExecStart=' "$SERVICE_FILE")

# Use parameter expansion to extract ram and max-disk values
ram_value=$(echo "$exec_line" | grep -oP '--ram=\K\d+')
max_disk_value=$(echo "$exec_line" | grep -oP '--max-disk \K\d+')

echo "Введите ОЗУ. Если хотите оставить текущую($ram_value ГБ) нажмите ENTER: "
read MEM

echo "Введите HDD. Если хотите оставить текущее значение ($max_disk_value ГБ) нажмите ENTER: : "
read HDD

if [ -n "$MEM" ]; then
    sed -i "s/--ram=[0-9]*/--ram=$MEM/" "$SERVICE_FILE"
fi

if [ -n "$HDD" ]; then
    sed -i "s/--max-disk [0-9]*/--max-disk $HDD/" "$SERVICE_FILE"
fi

systemctl stop pop
sudo systemctl daemon-reload
systemctl start pop

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u pop -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"