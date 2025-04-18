#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

config_file=~/drosera/drosera.toml
service_file="/etc/systemd/system/drosera.service"

read -p "Введите новый RPC адрес: " new_rpc
if [ -f "$config_file" ]; then
    sed -i "s|^ethereum_rpc = \".*\"|ethereum_rpc = \"$new_rpc\"|" "$config_file"
    echo "RPC изменен в файле $config_file"
else
    echo "Файл $config_file не найден"
    exit 1
fi

if [ ! -f "$service_file" ]; then
    echo "Файл сервиса не найден: $service_file"
    exit 1
fi

sed -i -E 's|--eth-rpc-url [^ ]+|--eth-rpc-url '"$new_rpc"'|g' "$service_file"

echo "Изменен --eth-rpc-url в файле $service_file"



systemctl daemon-reexec
systemctl daemon-reload
systemctl restart drosera.service
echo "Сервис перезапущен."
