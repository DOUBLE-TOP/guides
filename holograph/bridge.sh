#!/bin/bash

function logo {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh)
}

function line {
    echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

  function deploying {
    holograph create:contract
}

function minting {
    holograph create:nft
}

function deploying_to_blochains {
    holograph create:contract
}

function bridging {
    holograph bridge:nft
}



colors
line
logo
line
echo "Deploying a Collection"
line
deploying
line
echo "Minting an NFT"
minting
line
echo "Deploying Collections to Additional Blockchains"
deploying_to_blochains
line
echo "Bridging an NFT"
bridging
line
echo "Congratulations, it's the finish"
