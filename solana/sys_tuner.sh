#!/bin/bash

function install_rust {
    source $HOME/.profile
    if [ ! -d $HOME/.cargo/ ]; then
        curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
        source $HOME/.cargo/env
        rustup default nightly
        sleep 1
    fi
}

function install_sys_tuner {
    cargo install solana-sys-tuner --root $HOME/solana-sys-tuner
}

function create_sys_tuner_service {
    sudo bash -c "cat > /etc/systemd/system/sys_tuner.service<<EOF
[Unit]
Description=Solana Sys Tuner
After=network-online.target

[Service]
User=root
ExecStart=$HOME/solana-sys-tuner/bin/solana-sys-tuner --user $USER
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF"
}

function enable_sys_tuner_service {
    sudo systemctl daemon-reload
    sudo systemctl enable sys_tuner
}

function start_sys_tuner_service {
    sudo systemctl restart sys_tuner
}


function main {
    install_rust
    install_sys_tuner
    create_sys_tuner_service
    enable_sys_tuner_service
    start_sys_tuner_service
}

main
