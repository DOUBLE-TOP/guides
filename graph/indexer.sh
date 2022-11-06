#!/bin/bash

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)

mkdir -p $HOME/graph-indexer/{cli/scripts,configs}
wget -O $HOME/graph-indexer/docker-compose.yml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/docker-compose.yml
wget -O $HOME/graph-indexer/prometheus.yml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/prometheus.yml
wget -O $HOME/graph-indexer/shell https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/shell
wget -O $HOME/graph-indexer/configs/index_node.toml https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/configs/index_node.toml
wget -O $HOME/graph-indexer/cli/Dockerfile https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/cli/Dockerfile
wget -O $HOME/graph-indexer/cli/altDockerfile https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/cli/altDockerfile
wget -O $HOME/graph-indexer/cli/alt2Dockerfile https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/cli/alt2Dockerfile
wget -O $HOME/graph-indexer/cli/scripts/poi https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/graph/cli/scripts/poi
chmod +x $HOME/graph-indexer/{shell,cli/scripts/poi}

cd $HOME/graph-indexer/
docker-compose up -d
