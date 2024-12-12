#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

systemctl stop nexus

cd $HOME/.nexus/network-api
git chekcout 0.4.4

cd $HOME/.nexus/network-api/clients/cli
cargo build --release --bin prover

rm -rf $HOME/.nexus/network-api/clients/cli/prover
cp $HOME/.nexus/network-api/clients/cli/target/release/prover $HOME/.nexus/network-api/clients/cli/prover

systemctl start nexus

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"