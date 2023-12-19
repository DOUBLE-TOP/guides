#!/bin/bash

function go {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)
  sudo apt install libudev-dev -y
}

function rust {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh)
  source $HOME/.profile
}

function nodejs {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/node.sh)
}

function source_build_namada_latest {
    cd
    rm -rf namada
    git clone https://github.com/anoma/namada/
    cd namada
    git checkout v0.28.1
    make install
}

function protoc {
  cd $HOME && rustup update
  PROTOC_ZIP=protoc-23.3-linux-x86_64.zip
  curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v23.3/$PROTOC_ZIP
  sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
  sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
  rm -f $PROTOC_ZIP
}

function main {
    go
    rust
    nodejs
    protoc
    source_build_namada_latest
}

main
