#!/bin/bash

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh)
git clone https://github.com/anoma/namada-trusted-setup.git
cd namada-trusted-setup && git checkout v1.0.0-beta.11
cargo build --release --bin namada-ts --features cli
mv target/release/namada-ts /usr/local/bin
