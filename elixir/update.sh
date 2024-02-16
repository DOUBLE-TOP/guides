#!/bin/bash

cd $HOME/elixir/

docker kill ev
docker rm ev
docker pull elixirprotocol/validator:testnet-2
docker build . -t elixir-validator
docker run -it --restart unless-stopped -d --name ev elixir-validator