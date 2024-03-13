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

function install_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo "Docker is not installed. Installing Docker..."
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common 
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo usermod -aG docker $USER
        docker_compose_version=v2.16.0
        sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
        chmod +x /usr/bin/docker-compose
        echo "Docker installed successfully"
    else
        echo "Docker is already installed"
    fi
}

function request_password() {
    if [ -z "$DUSK_PASS" ]; then
        read -sp "password: " DUSK_PASS
        echo
        export DUSK_PASS
    fi
}

function fix_hosts {
    grep -q "165.232.95.210 bootstrap1.testnet.dusk.network" /etc/hosts || echo "165.232.95.210 bootstrap1.testnet.dusk.network" >> /etc/hosts
    grep -q "206.189.53.129 bootstrap2.testnet.dusk.network" /etc/hosts || echo "206.189.53.129 bootstrap2.testnet.dusk.network" >> /etc/hosts
}

function prepare_files {
  mkdir -p $HOME/rusk
  cd $HOME/rusk

  cat > prestart.sh <<EOF
#!/bin/bash

DIR="/opt/dusk"

if [ "\$(ls -A \$DIR)" ]; then
  echo "Cтартуем..."
else
  curl --proto "=https" --tlsv1.2 -sSfL https://github.com/dusk-network/itn-installer/releases/download/v0.1.8/itn-installer.sh | sh
fi
EOF

  cat > start.sh <<EOF
#!/bin/bash

# Запись ключей восстановления в лог
/opt/dusk/bin/rusk recovery-keys >> /var/log/rusk_recovery.log

# Запись состояния восстановления в лог
/opt/dusk/bin/rusk recovery-state >> /var/log/rusk_recovery.log

# Проверка консенсусных ключей
/opt/dusk/bin/check_consensus_keys.sh

# Запуск основного процесса
exec /opt/dusk/bin/rusk --config /opt/dusk/conf/rusk.toml --kadcast-bootstrap bootstrap1.testnet.dusk.network:9000 --kadcast-bootstrap bootstrap2.testnet.dusk.network:9000 --http-listen-addr 0.0.0.0:8980 > /opt/dusk/rusk.log
EOF


  cat > Dockerfile <<EOF
FROM ubuntu:22.04

WORKDIR /opt/dusk

ENV RUST_BACKTRACE=full \\
    RUSK_PROFILE_PATH=/opt/dusk/rusk

# Установка необходимых пакетов и выполнение всех операций одним слоем
RUN apt update && apt install -y unzip curl jq net-tools logrotate dnsutils

COPY start.sh /start.sh
COPY prestart.sh /prestart.sh

RUN chmod +x /start.sh
RUN chmod +x /prestart.sh

CMD ["/start.sh"]
EOF

  cat > docker-compose.yml <<EOF
version: '3'
services:
  dusk:
    network_mode: host
    build:
      context: .
    environment:
      - DUSK_CONSENSUS_KEYS_PASS=$DUSK_PASS
      - KADCAST_PUBLIC_ADDRESS=$IP:9900
      - KADCAST_LISTEN_ADDRESS=$IP:9900
    volumes:
      - ./dusk:/opt/dusk
      - ./.dusk:/root/.dusk
EOF
}

function build_container {
  docker-compose build
}

function start_dusk {
  docker-compose run dusk bash -c "/prestart.sh"
  docker-compose up -d
  sleep 15
  docker-compose run dusk bash -c "/opt/dusk/bin/rusk-wallet --state http://127.0.0.1:8980 --password \$DUSK_CONSENSUS_KEYS_PASS create --seed-file /opt/dusk/seed.txt"
  docker-compose run dusk bash -c "/opt/dusk/bin/rusk-wallet --state http://127.0.0.1:8980 --password \$DUSK_CONSENSUS_KEYS_PASS export -d /opt/dusk/conf -n consensus.keys"
}

function main {
  IP=$(curl -s ipinfo.io/ip)
  colors
  line
  logo
  line
  output_error "Enter your password to continue:"
  request_password
  line
  output "Installing Dusk Network..."
  line
  install_docker
  sudo apt install python3-requests -y
  line
  output "Preparing files..."
  prepare_files
  fix_hosts
  build_container
  start_dusk
  line
  output_normal "Installation complete"
  line
  output "Wish lifechange case with DOUBLETOP"
}

main