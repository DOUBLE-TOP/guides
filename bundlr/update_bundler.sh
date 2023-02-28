#!/bin/bash
cd $HOME/bundlr/validator-rust
git pull origin master
git submodule update --init --recursive
docker-compose up --build -d