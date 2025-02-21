#!/bin/bash
source $HOME/.cargo/env
source $HOME/.bashrc

cd $HOME/.nexus/network-api
git stash
git fetch --tags
git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1)

cd $HOME/.nexus/network-api/clients/cli && cargo run -r -- start --env beta

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"