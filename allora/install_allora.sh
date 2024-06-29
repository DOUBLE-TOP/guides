#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка Allora Worker"
echo "-----------------------------------------------------------------------------"

source .profile

# Check go version
GO_VERSION_OUTPUT=$(go version)
echo "$GO_VERSION_OUTPUT"

# Extract the version number (e.g., 1.20.12)
GO_VERSION=$(echo "$GO_VERSION_OUTPUT" | awk '{print $3}' | cut -d 'o' -f 2)

# Split the major and minor version numbers
MAJOR_VERSION=$(echo "$GO_VERSION" | cut -d '.' -f 1)
MINOR_VERSION=$(echo "$GO_VERSION" | cut -d '.' -f 2)

# Check if the Go version is 1.21 or higher
if [ "$MAJOR_VERSION" -gt "1" ] || { [ "$MAJOR_VERSION" -eq "1" ] && [ "$MINOR_VERSION" -ge "22" ]; }; then
  echo "Go version is 1.22 or higher."
else
  echo "Переустановите версию GO. Необходимая версия 1.22+"
  exit 1
fi

git clone https://github.com/allora-network/allora-chain.git && cd allora-chain
sed -i 's/^go 1.22.2$/go 1.22/' $HOME/allora-chain/go.mod
make all
allorad version

OUTPUT=$(allorad keys add testkey)

# Extract the seed phrase and address from the output
ADDRESS=$(echo "$OUTPUT" | grep -oP 'address: \K.*')
SEED_PHRASE=$(echo "$OUTPUT" | grep -A 1 "Important" | tail -n 1)

# Optional: Check if the address and seed phrase were successfully extracted
if [ -z "$ADDRESS" ]; then
  echo "Address could not be extracted."
  exit 1
else
  echo "Allora Address: $ADDRESS"
fi

# Optional: Check if the seed phrase was successfully extracted
if [ -z "$SEED_PHRASE" ]; then
  echo "Seed phrase could not be extracted."
  exit 1
else
  echo "Seed phrase successfully extracted."
  echo "Seed Phrase: $SEED_PHRASE"
fi

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"