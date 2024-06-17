#!/bin/bash

fetch_file_from_repo() {
    local file_path="$1"
    local local_filename="$2"
    
    local download_url
    download_url="$RAWFILE_BASE/$LATEST_TAG/$file_path?t=$(date +%s)"

    # Download the file using curl, and save it to the local filename. If the download fails,
    # exit with an error.
    curl -sS -o "$local_filename" "$download_url" || { echo "Failed to fetch $download_url."; exit 1; }
}

download_script() {
    # Make the ~/hubble directory if it doesn't exist
    mkdir -p ~/hubble
    
    local tmp_file
    tmp_file=$(mktemp)
    fetch_file_from_repo "$SCRIPT_FILE_PATH" "$tmp_file"

    mv "$tmp_file" ~/hubble/hubble.sh
    chmod +x ~/hubble/hubble.sh
}


echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды Farcaster"
echo "-----------------------------------------------------------------------------"


REPO="farcasterxyz/hub-monorepo"
RAWFILE_BASE="https://raw.githubusercontent.com/$REPO"
LATEST_TAG="@latest"
SCRIPT_FILE_PATH="scripts/hubble.sh"

download_script

cd $HOME/hubble
bash hubble.sh "upgrade"

echo "-----------------------------------------------------------------------------"
echo "Farcaster Node успешно установлена"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов:"
echo "docker logs -f --tail=100 hubble-hubble-1"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
