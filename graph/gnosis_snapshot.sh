#!/bin/bash

bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)

curl https://raw.githubusercontent.com/gnosischain/download-manager/multipart/releases/linux/amd64/download-manager --output ./download-manager
chmod +x ./download-manager
mv ./download-manager /usr/bin/
tmux new-session -d -s fetch-xdai-archive 'download-manager fetch -u https://gc-ne-archive.gnosis.io/xdai_archive.tar.gz -f xdai_archive.tar.gz -c 10 && tar -xvf xdai_archive.tar.gz && rm -f xdai_archive.tar.gz'
