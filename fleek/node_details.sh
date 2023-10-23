#!/bin/bash

# <!-- IGNORE: This line is intentional DO NOT MODIFY --><pre><script>document.querySelector('body').firstChild.textContent = '#!/bin/bash'</script>

# "Get Fleek Network" is an attempt to make our software more accessible.
# By providing scripts to automate the installation process of our software,
# we believe that it can help improve the onboarding experience of our users.
#
# Quick install: `curl https://get.fleek.network | bash`
#
# Contributing?
# - If you'd like to test changes locally based on a Lightning repo branch use the env var `USE_LIGHTNING_BRANCH`
# - If you'd like to test changes locally based on a get.fleek.network repo branch use the env var `USE_GET_BRANCH`
#
# Found an issue? Please report it here: https://github.com/fleek-network/get.fleek.network

# Defaults
defaultName="lightning"
defaultLightningBasePath="$HOME/.$defaultName"
defaultDockerContainerName="$defaultName-node"
defaultLightningKeystorePath="$defaultLightningBasePath/keystore"
defaultLightningKeystoreNodePemFilename="node.pem"
defaultLightningKeystoreConsensusPemFilename="consensus.pem"
defaultLightningKeystoreNodePemPath="$defaultLightningKeystorePath/$defaultLightningKeystoreNodePemFilename"
defaultLightningKeystoreConsensusPemPath="$defaultLightningKeystorePath/$defaultLightningKeystoreConsensusPemFilename"
defaultRPCUrl="https://rpc.testnet.fleek.network/rpc/v0"
defaultUnitPrecision="10^18"
defaultLightningSystemdServiceName="$defaultName"
defaultLightningSystemdServiceNameForDocker="docker-$defaultName"
defaultLightningSystemdServicePath="/etc/systemd/system/$defaultLightningSystemdServiceName.service"
defaultLightningSystemdServicePathForDocker="/etc/systemd/system/$defaultLightningSystemdServiceNameForDocker.service"
defaultLightningSystemdServiceName="docker-$defaultName"

# Utils
hasCommand() {
  command -v "$1" >/dev/null 2>&1
}

flkMinorUnitToFlk() {
  if hasCommand bc; then
    echo "$1 / $defaultUnitPrecision" | bc
  else
    sudo DEBIAN_FRONTEND=noninteractive apt-get install bc -yq

    flkMinorUnitToFlk
  fi
}

validateIpAddress() {
  local validate="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"

  [[ "$1" =~ $validate ]] && ping -c1 -W1 "$1" > /dev/null
}

findIp() {
  for url in "ipinfo.io/ip" "api.ipify.org" "ipecho.net/plain" "ifconfig.me" "ident.me"; do
    ip=$(curl -sw "\n" "$url")

    if validateIpAddress "$ip"; then
      echo "$ip"

      return
    fi
  done
}

# The white space before and after is intentional
cat << "ART"

  ⭐️ Fleek Network Node details ⭐️

              zeeeeee-
              z$$$$$$"
            d$$$$$$"
            d$$$$$P
          d$$$$$P
          $$$$$$"
        .$$$$$$"
      .$$$$$$"
      4$$$$$$$$$$$$$"
    z$$$$$$$$$$$$$"
    """""""3$$$$$"
          z$$$$P
          d$$$$"
        .$$$$$"
      z$$$$$"
      z$$$$P
    d$$$$$$$$$$"
    *******$$$"
        .$$$"
        .$$"
      4$P"
      z$"
    zP
    z"
  /

ART

echo
echo "★★★★★★★★★ 🌍 Website https://fleek.network"
echo "★★★★★★★★★ 📚 Documentation https://docs.fleek.network"
echo "★★★★★★★★★ 💾 Git repository https://github.com/fleek-network/lightning"
echo "★★★★★★★★★ 🤖 Discord https://discord.gg/fleekxyz"
echo "★★★★★★★★★ 🐤 Twitter https://twitter.com/fleek_net"
echo "★★★★★★★★★ 🎨 Ascii art by https://www.asciiart.eu"
echo

if [[ -f "$defaultLightningSystemdServicePathForDocker" ]] && grep -q 'docker run' "$defaultLightningSystemdServicePathForDocker"; then  echo "✅ Docker Lightning CLI found!"

  dockerInspectRes=$(sudo docker container inspect -f '{{.State.Running}}' "$defaultDockerContainerName" 2>&1 | xargs | grep 'true\|false')
  if [[ "$dockerInspectRes" == "" || "$dockerInspectRes" == "false" ]]; then

    if ! sudo systemctl restart "$defaultLightningSystemdServiceName"; then
      echo "👹 Oops! Failed to restart $defaultLightningSystemdServiceName"

      exit 1
    fi
  fi
else
  if ! hasCommand lgtn; then
    echo "👹 Oops! Failed to locate the Lightning CLI lgtn alias. This script is made to support default installations made with the tools or instructions, if you have a custom installation you're better of getting the details on your own."

    exit 1
  fi
fi

(
  exec < /dev/tty;

  echo


  if [[ ! -d "$defaultLightningKeystorePath" ]] || [[ ! -f "$defaultLightningKeystoreNodePemPath" ]] && [[ ! -f "$defaultLightningKeystoreConsensusPemPath" ]]; then
    echo "👹 Oops! Failed to find the keystore"
    echo
    echo "The keys are generated for you if you have installed with the assisted installer, followed the documentation recommendation or the Docker install."
    echo "If you missed the step, read the documentation instructions provided in https://docs.fleek.network/docs/node/install/#key-generator, or troubleshoot by learning how to manage the keystore in the guide here https://docs.fleek.network/guides/Node%20Operators/managing-the-keystore/ "

    exit 1
  fi

  if [[ -f "$defaultLightningSystemdServicePathForDocker" ]] && grep -q 'docker run' "$defaultLightningSystemdServicePathForDocker"; then
    keys=$(sudo docker exec -i lightning-node lgtn keys show | cut -d : -f 2)
  else
    keys=$(lgtn keys show | cut -d : -f 2)
  fi

  nodePubKey=$(echo "$keys" | sed -n '1p' | cut -d : -f 2 | xargs)
  consensusPubKey=$(echo "$keys" | sed -n '2p' | cut -d : -f 2 | xargs)
  ipAddr=$(findIp)
  hasStake=$(curl -sX POST \
    "$defaultRPCUrl" \
    -H 'Content-Type: application/json' \
    -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"flk_get_node_info\",\"params\":[\"$nodePubKey\"]}" | grep -Eo '"staked"[^,]*' | grep -Eo '[^:]*$' | cut -d "\"" -f 2)

  if [[ "$nodePubKey" == "" || "$consensusPubKey" == "" ]]; then
    echo "👹 Oops! Failed to get the public keys. Try again later!"
    echo "⚠️ WARNING: If this issue persists, report to us via our discord. Thank you!"

    exit 1
  elif [[ "$ipAddr" == "" ]]; then
    echo "⚠️ WARNING: Couldn't find the server IP address for some reason. You have to check it check manually or try again later!"
  fi

  echo
  echo
  echo "🤖 Your server details are the following"
  echo
  echo "The Node Public Key is $nodePubKey"
  echo "The Consensus Public Key is $consensusPubKey"

  if validateIpAddress "$ipAddr"; then
    echo "The Node Server IP address is $ipAddr"
  fi

  if [[ ! "$hasStake" -eq "" ]]; then
    flkAmount=$(flkMinorUnitToFlk "$hasStake")

    echo "The Node staked amount is $flkAmount FLK"
  fi

  echo
  echo "Learn more by checking our guides at https://docs.fleek.network"
  echo "✨ That's all!"
)