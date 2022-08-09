#!/bin/bash

cd $HOME/SubQ
git clone https://github.com/subquery/tutorials-council-proposals
cd tutorials-council-proposals
yarn
yarn codegen
yarn build
docker-compose up -d
