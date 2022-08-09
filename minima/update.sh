#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald

wget https://github.com/minima-global/Minima/raw/master/jar/minima.jar -O $HOME/minima.jar.new
sudo systemctl stop minima
sleep 5
mv $HOME/minima.jar $HOME/minima.jar.bk
mv $HOME/minima.jar.new $HOME/minima.jar

sudo tee <<EOF >/dev/null /etc/systemd/system/minima.service
[Unit]
Description=minima
[Service]
User=$USER
ExecStart=/usr/bin/java -Xmx1G -jar $HOME/minima.jar -daemon
Restart=always
RestartSec=100
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start minima
echo 'Minima updated successfully'
echo -e '\n\e[44mRun command to see logs: \e[0m\n'
echo 'journalctl -n 100 -f -u minima'
