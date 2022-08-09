#!/bin/bash

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash

mkdir $HOME/SubQ
cd $HOME/SubQ
git clone https://github.com/subquery/tutorials-account-transfers
cd tutorials-account-transfers

sudo tee <<EOF >/dev/null $HOME/SubQ/tutorials-account-transfers/package.json
{
  "name": "account-transfers",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc -b",
    "prepack": "rm -rf dist && npm build",
    "test": "jest",
    "codegen": "./node_modules/.bin/subql codegen"
  },
  "homepage": "https://github.com/subquery/subql-starter",
  "repository": "github:subquery/subql-starter",
  "files": [
    "dist",
    "schema.graphql",
    "project.yaml"
  ],
  "author": "sa",
  "license": "Apache-2.0",
  "devDependencies": {
    "@polkadot/api": "^6",
    "@subql/types": "latest",
    "typescript": "^4.1.3",
    "@subql/cli": "latest"
  }
}
EOF

sudo tee <<EOF >/dev/null $HOME/SubQ/tutorials-account-transfers/tsconfig.json
{
  "compilerOptions": {
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "esModuleInterop": true,
    "declaration": true,
    "importHelpers": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "module": "commonjs",
    "outDir": "dist",
    "rootDir": "src",
    "target": "es2017"
  },
  "include": [
    "src/**/*",
    "node_modules/@subql/types/dist/global.d.ts"
  ]
}
EOF

yarn
yarn codegen
yarn build
docker-compose up -d
