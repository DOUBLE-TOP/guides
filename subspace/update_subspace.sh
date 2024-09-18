#!/bin/bash

docker-compose -f $HOME/subspace_docker/docker-compose.yml down

sed -i 's/ghcr.io\/subspace\/node:.*/ghcr.io\/autonomys\/node:gemini-3h-2024-sep-17/g' $HOME/subspace_docker*/docker-compose.yml
sed -i 's/ghcr.io\/subspace\/farmer:.*/ghcr.io\/autonomys\/farmer:gemini-3h-2024-sep-17/g' $HOME/subspace_docker*/docker-compose.yml
sed -i 's/--state-pruning", "archive-canonical"/--state-pruning", "140000"/g' $HOME/subspace_docker*/docker-compose.yml

docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d
# docker-compose -f $HOME/subspace_docker_operator/docker-compose.yml up -d
