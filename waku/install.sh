#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git -y
}

function install_docker {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
}

function read_infura {
  if [ ! $INFURA_KEY ]; then
  echo -e "Введите ваш url infura или alchemy. Пример url'a - https://sepolia.infura.io/v3/ТУТ_ВАШ_КЛЮЧ"
  line_1
  read INFURA_KEY
  fi
}

function read_wallet {
  if [ ! $WAKU_WALLET ]; then
  echo -e "Введите ваш приватник от ETH кошелека на котором есть как минимум 0.1 ETH в сети Sepolia"
  line_1
  read WAKU_WALLET
  fi
}

function read_pass {
  if [ ! $WAKU_PASS ]; then
  echo -e "Введите(придумайте) пароль который будет использваться для сетапа ноды"
  line_1
  read WAKU_PASS
  fi
}

function git_clone {
  git clone https://github.com/waku-org/nwaku-compose
  cd nwaku-compose
  cp .env.example .env
}

function env {
  sudo tee <<EOF >/dev/null $HOME/nwaku-compose/.env
ETH_CLIENT_ADDRESS=$INFURA_KEY                                  # RPC URL for accessing testnet via HTTP.
ETH_TESTNET_KEY=$WAKU_WALLET                                    # Privatekey of testnet where you have sepolia ETH that would be staked into RLN contract
RLN_RELAY_CRED_PASSWORD="$WAKU_PASS"                            # Password you would like to use to protect your RLN membership

# Advanced
NWAKU_IMAGE=
NODEKEY=
DOMAIN=
EXTRA_ARGS=
RLN_RELAY_CONTRACT_ADDRESS=
EOF
}

function rnl {
  ./register_rln.sh
}

function docker_file { 
  sudo tee <<EOF >/dev/null $HOME/nwaku-compose/docker-compose.yml
version: "3.7"
x-logging: &logging
  logging:
    driver: json-file
    options:
      max-size: 1000m

# Environment variable definitions
x-eth-client-address: &eth_client_address ${ETH_CLIENT_ADDRESS:-} # Add your ETH_CLIENT_ADDRESS after the "-"

x-rln-environment: &rln_env
  RLN_RELAY_CONTRACT_ADDRESS: ${RLN_RELAY_CONTRACT_ADDRESS:-0xF471d71E9b1455bBF4b85d475afb9BB0954A29c4}
  RLN_RELAY_CRED_PATH: ${RLN_RELAY_CRED_PATH:-} # Optional: Add your RLN_RELAY_CRED_PATH after the "-"
  RLN_RELAY_CRED_PASSWORD: ${RLN_RELAY_CRED_PASSWORD:-} # Optional: Add your RLN_RELAY_CRED_PASSWORD after the "-"

x-pg-pass: &pg_pass ${POSTGRES_PASSWORD:-test123}
x-pg-user: &pg_user ${POSTGRES_USER:-postgres}

x-pg-environment: &pg_env
  POSTGRES_USER: *pg_user
  POSTGRES_PASSWORD: *pg_pass

x-pg-exporter-env: &pg_exp_env
  environment:
    POSTGRES_PASSWORD: *pg_pass
    DATA_SOURCE_URI: postgres?sslmode=disable
    DATA_SOURCE_USER: *pg_user
    DATA_SOURCE_PASS: *pg_pass
    PG_EXPORTER_EXTEND_QUERY_PATH: /etc/pgexporter/queries.yml

# Services definitions
services:
  nwaku:
    image: ${NWAKU_IMAGE:-harbor.status.im/wakuorg/nwaku:v0.25.0}
    restart: on-failure
    ports:
      - 30304:30304/tcp
      - 30304:30304/udp
      - 8545:8545/tcp
      - 9005:9005/udp
      - 8003:8003
      - 80:80 #Let's Encrypt
      - 8000:8000/tcp #WSS
      - 8645:8645
    <<:
      - *logging
    environment:
      DOMAIN: ${DOMAIN}
      NODEKEY: ${NODEKEY}
      RLN_RELAY_CRED_PASSWORD: "${RLN_RELAY_CRED_PASSWORD}"
      ETH_CLIENT_ADDRESS: *eth_client_address
      EXTRA_ARGS: ${EXTRA_ARGS}
      <<:
        - *pg_env
        - *rln_env
    volumes:
      - ./run_node.sh:/opt/run_node.sh:Z
      - ${CERTS_DIR:-./certs}:/etc/letsencrypt/:Z
      - ./rln_tree:/etc/rln_tree/:Z
      - ./keystore:/keystore:Z
    entrypoint: sh
    command:
      - /opt/run_node.sh
    depends_on:
      - postgres

  # TODO: Commented until ready
  #waku-frontend:
  #  # TODO: migrate to waku-org
  #  image: docker.io/alrevuelta/waku-frontend:latest
  #  #command:
  #  #  - xxx
  #  ports:
  #    - 4000:3000
  #  restart: on-failure:5
  #  depends_on:
  #    - nwaku

  prometheus:
    image: docker.io/prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus-config.yml:/etc/prometheus/prometheus.yml:Z
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    ports:
      - 9090:9090
    restart: on-failure:5
    depends_on:
      - postgres-exporter
      - nwaku

  grafana:
    image: docker.io/grafana/grafana:latest
    env_file:
      - ./monitoring/configuration/grafana-plugins.env
    volumes:
      - ./monitoring/configuration/grafana.ini:/etc/grafana/grafana.ini:Z
      - ./monitoring/configuration/dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml:Z
      - ./monitoring/configuration/datasources.yaml:/etc/grafana/provisioning/datasources/datasources.yaml:Z
      - ./monitoring/configuration/dashboards:/var/lib/grafana/dashboards/:Z
      - ./monitoring/configuration/customizations/custom-logo.svg:/usr/share/grafana/public/img/grafana_icon.svg:Z
      - ./monitoring/configuration/customizations/custom-logo.svg:/usr/share/grafana/public/img/grafana_typelogo.svg:Z
      - ./monitoring/configuration/customizations/custom-logo.png:/usr/share/grafana/public/img/fav32.png:Z
    ports:
      - 3000:3000
    restart: on-failure:5
    depends_on:
      - prometheus

  postgres:
    # This service is used when the Waku node has the 'store' protocol enabled
    # and the store-message-db-url is set to use Postgres
    image: postgres:15.4-alpine3.18
    restart: on-failure:5
    environment:
      <<: *pg_env
    volumes:
      - ./postgres_cfg/postgresql.conf:/etc/postgresql/postgresql.conf:Z
      - ./postgres_cfg/db.sql:/docker-entrypoint-initdb.d/db.sql:Z
      - ${PG_DATA_DIR:-./postgresql}:/var/lib/postgresql/data:Z
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    ports: []
    #  - 5432:5432
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d postgres"]
      interval: 30s
      timeout: 60s
      retries: 5
      start_period: 80s

  postgres-exporter:
    # Service aimed to scrape information from Postgres and post it to Prometeus
    image: quay.io/prometheuscommunity/postgres-exporter:v0.12.0
    restart: on-failure:5
    <<: *pg_exp_env
    volumes:
      - ./monitoring/configuration/postgres-exporter.yml:/etc/pgexporter/postgres-exporter.yml:Z
      - ./monitoring/configuration/pg-exporter-queries.yml:/etc/pgexporter/queries.yml:Z
    command:
      # Both the config file and 'DATA_SOURCE_NAME' should contain valid connection info
      - --config.file=/etc/pgexporter/postgres-exporter.yml
    depends_on:
      - postgres
EOF
}

function docker_compose_up {
  docker-compose -f $HOME/nwaku-compose/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml restart \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml logs -f --tail=100 \n ${NORMAL}"
  ip_address=$(hostname -I | awk '{print $1}') >/dev/null
  echo -e "${GREEN}Для проверки дашборда графаны, перейдите по ссылке: ${NORMAL}"
  echo -e "${RED}   http://$ip_address:3000/d/yns_4vFVk/nwaku-monitoring \n ${NORMAL}"
}

colors
line_1
logo
line_2
read_infura
line_2
read_wallet
line_2
read_pass
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_ufw
install_docker
line_1
echo -e "Клонируем репозиторий, готовим env и регистрируем rln"
line_1
git_clone
env
rnl
line_1
echo -e "Запускаем docker контейнеры для waku"
line_1
docker_file
docker_compose_up
line_2
echo_info
line_2
