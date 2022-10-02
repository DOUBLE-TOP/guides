#!/bin/bash

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)

mkdir -p $HOME/graph-indexer
wget -O $HOME/graph-indexer/docker-compose.yml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/docker-compose.yml
wget -O $HOME/graph-indexer/prometheus.yml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/prometheus.yml
