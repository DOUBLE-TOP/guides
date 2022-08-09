#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Выполняем фикс"
echo "-----------------------------------------------------------------------------"
systemctl stop sui
rm -rf /usr/local/bin/sui-node
sudo sed -i "/ExecStart=/c\ExecStart=/usr/bin/sui-node --config-path /root/.sui/fullnode.yaml" /etc/systemd/system/sui.service
systemctl daemon-reload
systemctl restart sui
echo "-----------------------------------------------------------------------------"
echo "Проверьте логи journalctl -n 100 -f -u sui все должно рабоать ❤️ "
echo "-----------------------------------------------------------------------------"
