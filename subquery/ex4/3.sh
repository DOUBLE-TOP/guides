#!/bin/bash
cd $HOME/staking-rewards
docker-compose down

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/3/schema.graphql > $HOME/staking-rewards/schema.graphql
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/subquery/ex4/3/mappingHandlers.ts > $HOME/staking-rewards/src/mappings/mappingHandlers.ts
yarn codegen
yarn build
rm -rf $HOME/staking-rewards/.data

docker-compose up -d
