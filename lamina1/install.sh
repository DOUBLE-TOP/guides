#!/bin/bash

# Build GLIBC 2.34 from source to path /opt/glibc-2.34
function build_glibc {

}

# Install Lamina1
function add_lamina1_repo {
    sudo echo "deb [trusted=yes arch=amd64] https://snapshotter.lamina1.global/ubuntu jammy main"  > /etc/apt/sources.list.d/lamina1.list
}

function install_lamina1 {
    sudo apt-get update
    sudo apt-get install -y lamina1-node
}

function main {
    add_lamina1_repo
    install_lamina1
}

main
