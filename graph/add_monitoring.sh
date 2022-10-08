#!/bin/bash

if [ ! $indexer_domain ]; then
	read -p "Введите домен индексера(без https://): " indexer_domain
fi
echo 'Ваш домен: ' $indexer_domain
sleep 1
echo 'export indexer_domain='$indexer_domain >> $HOME/.bash_profile

sudo tee <<EOF >/dev/null $HOME/graph-indexer/prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'docker-host-alpha'

# A scrape configuration containing exactly one endpoint to scrape.
scrape_configs:
  - job_name: 'nodeexporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['nodeexporter:9100']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$indexer_domain'

  - job_name: 'cadvisor'
    scrape_interval: 5s
    static_configs:
      - targets: ['cadvisor:8080']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$indexer_domain'

  - job_name: 'prometheus'
    metrics_path: /prometheus/metrics
    scrape_interval: 10s
    static_configs:
      - targets: ['localhost:9090']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$indexer_domain'



  - job_name: 'index-node'
    scrape_interval: 5s
    static_configs:
      - targets: ['index-node:8040']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$indexer_domain'

remote_write:
  - url: http://doubletop:doubletop@vm.razumv.tech:8080/api/v1/write
EOF

cd $HOME/graph-indexer/
docker-compose restart prometheus
