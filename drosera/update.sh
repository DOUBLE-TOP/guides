#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Останавливаем drosera сервис"
service drosera stop
source /root/.profile
echo "Обновляемм Drosera CLI"
curl -s -L https://app.drosera.io/install | bash > /dev/null 2>&1
droseraup &>/dev/null

if [ ! -f drosera.toml ]; then
  cd drosera
fi
echo "Обновляем значение drosera_rpc в файле drosera.toml"
sed -i 's|^drosera_rpc =.*|drosera_rpc = "https://relay.testnet.drosera.io"|' drosera.toml

# get private key to do drosera apply with it
SERVICE_FILE="/etc/systemd/system/drosera.service"
private_key=$(grep 'ExecStart=' "$SERVICE_FILE" | sed -n 's/.*--eth-private-key \([^ ]*\).*/\1/p')

drosera apply --private-key="$private_key"

echo "Стартуем drosera сервис"
service drosera start
