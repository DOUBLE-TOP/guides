#!/bin/bash

function install_deps {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
  source .profile
  sudo apt-get install jq mc wget git -y &>/dev/null
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 &>/dev/null
  sudo chmod a+x /usr/local/bin/yq
}

function source_code {
  cd $HOME
  git clone https://github.com/aptos-labs/aptos-core.git
  cd $HOME/aptos-core
  git fetch
  git checkout origin/devnet
  echo y | ./scripts/dev_setup.sh
  source ~/.cargo/env
}

function fetch_code {
  cd $HOME/aptos-core
  git fetch && git pull origin devnet
}

function update_genesis_files {
  mkdir -p $HOME/aptos/
  wget -O $HOME/aptos/genesis.blob https://devnet.aptoslabs.com/genesis.blob
  wget -O $HOME/aptos/waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
}

function build_tools {
  $HOME/.cargo/bin/cargo  build -p aptos-operational-tool --release
  mv $HOME/aptos-core/target/release/aptos-operational-tool /usr/local/bin
}

function build_node {
  $HOME/.cargo/bin/cargo  build -p aptos-node --release
  mv $HOME/aptos-core/target/release/aptos-node /usr/local/bin
}

function wget_tools {
  sudo wget -O /usr/local/bin/aptos-operational-tool http://65.21.193.112/aptos-operational-tool
  sudo chmod +x /usr/local/bin/aptos-operational-tool
}

function wget_node {
  sudo wget -O /usr/local/bin/aptos-node http://65.21.193.112/aptos-node
  sudo chmod +x /usr/local/bin/aptos-node
}

function create_identity {
  sudo mkdir -p $HOME/aptos/identity
  aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/aptos/identity/private-key.txt
  aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/aptos/identity/private-key.txt --output-file $HOME/aptos/identity/peer-info.yaml
  sleep 1
}

function get_vars {
  PEER_ID=$(sed -n 2p $HOME/aptos/identity/peer-info.yaml | sed 's/.$//'  | sed 's/://g')
  PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
  WAYPOINT=$(cat $HOME/aptos/waypoint.txt)
}

function fix_config {
  wget -O $HOME/aptos/seeds.yaml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aptos/seeds.yaml
  wget -O $HOME/aptos/public_full_node.yaml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/aptos/public_full_node.yaml
  sed -i '/network_id: "public"$/a\
      identity:\
        type: "from_config"\
        key: "'$PRIVATE_KEY'"\
        peer_id: "'$PEER_ID'"' $HOME/aptos/public_full_node.yaml

  /usr/local/bin/yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml $HOME/aptos/seeds.yaml

  sed -i 's|127.0.0.1|0.0.0.0|' $HOME/aptos/public_full_node.yaml
  sed -i -e "s|genesis_file_location: .*|genesis_file_location: \"$HOME\/aptos\/genesis.blob\"|" $HOME/aptos/public_full_node.yaml
  sed -i -e "s|data_dir: .*|data_dir: \"$HOME\/aptos\/data\"|" $HOME/aptos/public_full_node.yaml
  sed -i -e "s|0:01234567890ABCDEFFEDCA098765421001234567890ABCDEFFEDCA0987654210|$WAYPOINT|" $HOME/aptos/public_full_node.yaml
}

function fix_journal {
  sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
  Storage=persistent
EOF
  sudo systemctl restart systemd-journald
}

function bin_service {
  sudo tee <<EOF >/dev/null /etc/systemd/system/aptos.service
  [Unit]
    Description=Aptos daemon
    After=network-online.target
  [Service]
    User=$USER
    ExecStart=/usr/local/bin/aptos-node -f $HOME/aptos/public_full_node.yaml
    Restart=on-failure
    RestartSec=3
    LimitNOFILE=4096
  [Install]
    WantedBy=multi-user.target
EOF

  sudo systemctl enable aptos
  sudo systemctl daemon-reload
  sudo systemctl restart aptos
  echo "Сервис обновлен, демон перезагружен"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

colors
line
logo
line
echo -e "${GREEN}1. Ставим зависимости... ${NORMAL}" && sleep 1
line
install_deps

echo -e "${GREEN}2 Билдим бинарники aptos-operational-tool aptos-node... ${NORMAL}" && sleep 1
line
source_code
# build_tools
# build_node
wget_tools
wget_node
line
echo -e "${GREEN}3. Скачиваем Aptos FullNode конфиги ... ${NORMAL}" && sleep 1
update_genesis_files
line
echo -e "${GREEN}4.1 Создаем идентити ${NORMAL}"
create_identity
get_vars
if [ ! -z "$PRIVATE_KEY" ]
then
    echo -e "\e[1m\e[92m Identity успешно созданы ${NORMAL}"
    echo -e "\e[1m\e[92m Peer Id: ${NORMAL}" $PEER_ID
    echo -e "\e[1m\e[92m Private Key:  ${NORMAL}" $PRIVATE_KEY
else
    rm $HOME/aptos/identity/id.json
    rm $HOME/aptos/identity/private-key.txt
    echo -e "\e[1m\e[91m Wasn't able to create the Identity. FullNode will be started without the identity, identity can be added manually ${NORMAL}"
fi

if [[ -f $HOME/aptos/identity/private-key.txt ]]
then
    get_vars
    if [ ! -z "$PRIVATE_KEY" ]
    then
        sleep 1
    else
        rm $HOME/aptos/identity/private-key.txt
        create_identity
    fi
    line
else
    create_identity
    line
fi
get_vars
fix_config
line
echo -e "${GREEN}5. Запуск Aptos FullNode ... ${NORMAL}" && sleep 5
line
fix_journal
bin_service
line
echo -e "${GREEN}Aptos FullNode запущена ${NORMAL}"
line

if [ ! -z "$PRIVATE_KEY" ]
then
    echo -e "${GREEN}Путь к приватнику, рекомендуется забекапить: ${NORMAL}"
    echo -e "${RED}"    $HOME/aptos/identity/private-key.txt" \n ${NORMAL}"
    echo -e "${GREEN}Путь к файлу пира, рекомендуется забекапить: ${NORMAL}"
    echo -e "${RED}"    $HOME/aptos/identity/peer-info.yaml" \n ${NORMAL}"
fi

echo -e "${GREEN}Для проверки синка: ${NORMAL}"
echo -e "${RED}    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type \n ${NORMAL}"

echo -e "${GREEN}Для проверки логов: ${NORMAL}"
echo -e "${RED}    journalctl -n 100 -f -u aptos \n ${NORMAL}"

echo -e "${GREEN}Для остановки: ${NORMAL}"
echo -e "${RED}    sudo systemctl stop aptos \n ${NORMAL}"
