#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление Dill Alps ноды"
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null


curl -sO https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/upgrade.sh
chmod +x upgrade.sh
sed -i '/\.\/start_dill_node\.sh/,/exit 1/!b;/if \[ \$\? -ne 0 \]; then/,/^fi$/d;' "$HOME/upgrade.sh"
sed -i '/if \[ \$\? -ne 0 \]; then/,/^fi$/d;' "$HOME/upgrade.sh"
./upgrade.sh

cd $HOME/dill
curl -sO https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dill/dill_service.sh
chmod +x dill_service.sh

sed -i 's|monitoring-port  9080 tcp|monitoring-port  8380 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-http.port 8545 tcp|exec-http.port 8945 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-port 30303 tcp&&udp|exec-port 30305 tcp&&udp|' "$HOME/dill/default_ports.txt"

sed -i 's|nohup \$PJROOT/\$NODE_BIN \$COMMON_FLAGS \$DISCOVERY_FLAGS \$VALIDATOR_FLAGS \$PORT_FLAGS > /dev/null 2>&1 &|./dill_service.sh|' "$HOME/dill/start_dill_node.sh"

bash $HOME/dill/start_dill_node.sh

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"