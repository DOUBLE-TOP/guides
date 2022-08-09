#!/bin/bash

cd $HOME/SubQ
git clone https://github.com/subquery/tutorials-account-transfer-reverse-lookups.git
cd tutorials-account-transfer-reverse-lookups

sudo tee <<EOF >/dev/null $HOME/SubQ/tutorials-account-transfer-reverse-lookups/package.json
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

sudo tee <<EOF >/dev/null $HOME/SubQ/tutorials-account-transfer-reverse-lookups/tsconfig.json
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
