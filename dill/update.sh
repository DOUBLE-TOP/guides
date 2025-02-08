#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление Dill Alps ноды"
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null

# Проверяем установлен ли вообще дилл и если да - стопаем сервисники удалем сам файл, стопаем нохап запуск
if [ -d "$HOME/dill" ]; then
    sudo systemctl stop dill &>/dev/null
    sudo systemctl disable dill &>/dev/null
    sudo systemctl daemon-reload &>/dev/null
    cd $HOME/dill
    bash stop_dill_node.sh
    rm -f /etc/systemd/system/dill.service
fi

cd $HOME

# Качаем скрипт апгрейда и удаляем строки по старту ноды и удаляем проверки запущена нода или нет
curl -sO https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/upgrade.sh
chmod +x upgrade.sh
sed -i 's|\./start_dill_node\.sh| |' "$HOME/upgrade.sh"
./upgrade.sh &>/dev/null
# rm -rf $HOME/upgrade.sh

# Качаем скрипт для запуска через сервис
cd $HOME/dill
curl -sO https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dill/dill_service.sh
chmod +x dill_service.sh

# Меняем дефолтные порты
sed -i 's|monitoring-port  9080 tcp|monitoring-port  8380 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-http.port 8545 tcp|exec-http.port 8945 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-port 30303 tcp|exec-port 30305 tcp|g; s|exec-port 30303 udp|exec-port 30305 udp|g' "$HOME/dill/default_ports.txt"

# Заменяем нохап запуск на создание сервисника
sed -i 's|nohup \$PJROOT/\$NODE_BIN \$COMMON_FLAGS \$DISCOVERY_FLAGS \$VALIDATOR_FLAGS \$PORT_FLAGS > /dev/null 2>&1 &|\$PJROOT/dill_service.sh \"\$PJROOT/\$NODE_BIN \$COMMON_FLAGS \$DISCOVERY_FLAGS \$VALIDATOR_FLAGS \$PORT_FLAGS\"|' "$HOME/dill/start_dill_node.sh"

# Запускаем скрипт для старта ноды
bash $HOME/dill/start_dill_node.sh

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"