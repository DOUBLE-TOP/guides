#!/bin/bash

function go {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)
}

function source_build_namada_latest {
    cd
    rm -rf namada
    git clone https://github.com/anoma/namada/
    cd namada
    git checkout v0.28.1
    make install
}

function main {
    go
    source_build_namada_latest
}

main
