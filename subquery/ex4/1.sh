#!/bin/bash

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/1/schema.graphql > $HOME/staking-rewards/schema.graphql
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/1/project.yaml > $HOME/staking-rewards/project.yaml
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/1/mappingHandlers.ts > $HOME/staking-rewards/src/mappings/mappingHandlers.ts
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/1/docker-compose.yml > $HOME/staking-rewards/docker-compose.yml
yarn install
yarn codegen
yarn build
docker-compose up -d
