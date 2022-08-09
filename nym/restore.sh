#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

if [ ! -e $HOME/nym_keys.tar.gz ]; then
	echo "Отсутствует архив с бекапом, загрузите его и повторите заново"
else
  cd $HOME
  sudo apt update
  sudo apt install make clang pkg-config libssl-dev build-essential git mc -y
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
	rustup default stable
  source $HOME/.cargo/env
  tar xvf nym_keys.tar.gz
  export NYM_NODENAME=`ls ~/.nym/mixnodes/`
  ip_addr=$(curl -s ifconfig.me)
  sed -i -e 's/^\(listening_address *=\).*/\1 '\"$ip_addr\"'/' $HOME/.nym/mixnodes/*/config/config.toml
  sed -i -e 's/^\(announce_address *=\).*/\1 '\"$ip_addr\"'/' $HOME/.nym/mixnodes/*/config/config.toml
  git clone https://github.com/nymtech/nym.git
  cd $HOME/nym
  git checkout v0.11.0
  cargo build --release
  echo 'export PATH=$HOME/nym/target/release:$PATH' >> $HOME/.bashrc
  source $HOME/.bashrc
  sudo tee <<EOF >/dev/null /etc/systemd/system/nym.service
[Unit]
Description=nym
[Service]
LimitNOFILE=1024000
User=$USER
ExecStart=$HOME/nym/target/release/nym-mixnode run --id $NYM_NODENAME
KillSignal=SIGINT
Restart=always
RestartSec=30
StartLimitInterval=350
StartLimitBurst=10000000
[Install]
WantedBy=multi-user.target
EOF

  sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

  sudo systemctl restart systemd-journald
  sudo systemctl daemon-reload
  sudo systemctl start nym
  sudo systemctl enable nym

fi
