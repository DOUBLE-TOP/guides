#!/bin/bash
cd $HOME/staking-rewards
docker-compose down
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/2/schema.graphql > $HOME/staking-rewards/schema.graphql
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/2/project.yaml > $HOME/staking-rewards/project.yaml
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/2/mappingHandlers.ts > $HOME/staking-rewards/src/mappings/mappingHandlers.ts
yarn codegen
yarn build
docker-compose up -d
