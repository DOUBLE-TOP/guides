#!/bin/bash

cd $HOME/elixir/

docker kill elixir &>/dev/null
docker rm -f elixir &>/dev/null
sed -i 's/^ENV=testnet-3/ENV=prod/' $HOME/elixir/.env
docker pull elixirprotocol/validator --platform linux/amd64

docker run --env-file $HOME/elixir/.env --name elixir --platform linux/amd64 --restart always -p 17690:17690 elixirprotocol/validator