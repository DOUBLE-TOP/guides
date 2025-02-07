#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Бекап Alpes тестнета"
echo "-----------------------------------------------------------------------------"

sudo systemctl stop dill &>/dev/null

cd $HOME
mkdir -p dill_backups
mkdir -p dill_backups/alps

cp -r $HOME/dill/keystore $HOME/dill_backups/alps/keystore &>/dev/null
cp -r $HOME/dill/validator_keys $HOME/dill_backups/alps/validator_keys &>/dev/null
cp $HOME/dill/walletPw.txt $HOME/dill_backups/alps/walletPw.txt &>/dev/null
cp $HOME/dill/validators.json $HOME/dill_backups/alps/validators.json &>/dev/null

sudo systemctl disable dill &>/dev/null
sudo systemctl daemon-reload &>/dev/null

rm -rf $HOME/dill
rm -f /etc/systemd/system/dill.service

echo "-----------------------------------------------------------------------------"
echo "Миграция для Ваку"
echo "-----------------------------------------------------------------------------"

if ss -tuln | grep -q ":4000"; then
  docker compose -f $HOME/nwaku-compose/docker-compose.yml down
  sed -i 's/127\.0\.0\.1:4000:4000/0.0.0.0:4044:4000/g' $HOME/nwaku-compose/docker-compose.yml
  docker compose -f $HOME/nwaku-compose/docker-compose.yml up -d
else
  echo "Порт 4000 свободен."
fi

echo "-----------------------------------------------------------------------------"
echo "Установка Dill Alps ноды"
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null


curl -sO https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/dill.sh
chmod +x dill.sh
sed -i 's|$DILL_DIR/1_launch_dill_node.sh| |' "$HOME/dill.sh"
./dill.sh

cd $HOME/dill
curl -sO https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dill/dill_service.sh
chmod +x dill_service.sh

sed -i 's|monitoring-port  9080 tcp|monitoring-port  8380 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-http.port 8545 tcp|exec-http.port 8945 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-port 30303 tcp&&udp|exec-port 30305 tcp&&udp|' "$HOME/dill/default_ports.txt"

sed -i 's|nohup \$PJROOT/\$NODE_BIN \$COMMON_FLAGS \$DISCOVERY_FLAGS \$VALIDATOR_FLAGS \$PORT_FLAGS > /dev/null 2>&1 &|./dill_service.sh \"\$PJROOT/\$NODE_BIN \$COMMON_FLAGS \$DISCOVERY_FLAGS \$VALIDATOR_FLAGS \$PORT_FLAGS\"|' "$HOME/dill/start_dill_node.sh"

bash $HOME/dill/start_dill_node.sh

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"