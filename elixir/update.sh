#!/bin/bash

cd $HOME/elixir/

docker kill elixir
docker rm -f elixir
docker pull elixirprotocol/validator:v3
docker run -d --env-file $HOME/elixir/.env --name elixir --restart unless-stopped elixirprotocol/validator:v3