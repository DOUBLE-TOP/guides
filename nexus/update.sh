#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

systemctl stop nexus

cd $HOME/.nexus/network-api

git fetch
git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1)

cd $HOME/.nexus/network-api/clients/cli
cargo build --release --bin prover

rm -rf $HOME/.nexus/network-api/clients/cli/prover
cp $HOME/.nexus/network-api/clients/cli/target/release/prover $HOME/.nexus/network-api/clients/cli/prover

systemctl start nexus

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"