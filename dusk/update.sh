#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  YELLOW="\e[33m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function output {
  echo -e "${YELLOW}$1${NORMAL}"
}

function output_error {
  echo -e "${RED}$1${NORMAL}"
}

function output_normal {
  echo -e "${GREEN}$1${NORMAL}"
}

function prepare_files {
  cat > start.sh <<EOF
#!/bin/bash

# /opt/dusk/bin/rusk recovery-keys >> /var/log/rusk_recovery.log

# /opt/dusk/bin/rusk recovery-state >> /var/log/rusk_recovery.log

# /opt/dusk/bin/check_consensus_keys.sh

exec /opt/dusk/bin/rusk --config /opt/dusk/conf/rusk.toml --kadcast-bootstrap bootstrap1.testnet.dusk.network:9000 --kadcast-bootstrap bootstrap2.testnet.dusk.network:9000 --http-listen-addr 0.0.0.0:8980 > /opt/dusk/rusk.log
EOF
}

function fix_hosts {
    grep -q "165.232.95.210 bootstrap1.testnet.dusk.network" /etc/hosts || echo "165.232.95.210 bootstrap1.testnet.dusk.network" >> /etc/hosts
    grep -q "206.189.53.129 bootstrap2.testnet.dusk.network" /etc/hosts || echo "206.189.53.129 bootstrap2.testnet.dusk.network" >> /etc/hosts
}

# Вызов функции для исполнения
fix_hosts


function update {
    cd $HOME/rusk
    docker-compose down
    cp -r dusk dusk-backup
    docker rmi -f rusk-dusk:latest
    docker-compose build
    docker-compose run dusk bash -c "curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dusk/itn-installer.sh | bash"
    docker-compose up -d 
}

function main {
    colors
    logo
    line
    output "Обновление Dusk Network"
    line
    prepare_files
    fix_hosts
    update
    line
    output_normal "Обновление завершено"
    line
}

main