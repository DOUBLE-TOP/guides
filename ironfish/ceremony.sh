#!/bin/bash

source $HOME/.profile

if ! command -v tmux &>/dev/null; then
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
fi

if ! command -v npm &>/dev/null; then
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh)
fi

npm install -g ironfish