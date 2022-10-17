#!/bin/bash

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

function prom_token {
  if [ ! ${PROM_REMOTE_WRITE_TOKEN} ]; then
  echo "Введите токен мониторинга"
  line
  read PROM_REMOTE_WRITE_TOKEN
  fi
}

function set_token {
  tee $HOME/charon-distributed-validator-node/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval:     12s # Set the scrape interval to every 12 seconds. Default is every 1 minute.
  evaluation_interval: 12s # Evaluate rules every 12 seconds. The default is every 1 minute.

remote_write:
  - url: https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push
    authorization:
      credentials: 436764:$PROM_REMOTE_WRITE_TOKEN
    name: obol-prom

scrape_configs:
  - job_name: 'geth'
    metrics_path: /debug/metrics/prometheus
    static_configs:
      - targets: ['geth:6060']
  - job_name: 'lighthouse'
    static_configs:
      - targets: ['lighthouse:5054']
  - job_name: 'charon'
    static_configs:
      - targets: ['charon:3620']
  - job_name: 'teku'
    static_configs:
      - targets: ['teku:8008']
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
EOF
}

colors
line
logo
line
prom_token
line
set_token
docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml restart prometheus
line
echo "Готово, теперь ваши метрики отправляются команде Obol"
