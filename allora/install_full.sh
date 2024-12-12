#!/bin/bash

# Color codes for messages
BOLD="\033[1m"
UNDERLINE="\033[4m"
LIGHT_BLUE="\033[1;34m"     # Light Blue for primary messages
BRIGHT_GREEN="\033[1;32m"   # Bright Green for success messages
MAGENTA="\033[1;35m"        # Magenta for titles
RESET="\033[0m"             # Reset to default color

echo -e "${MAGENTA}Starting installation...${RESET}"

# Update and install necessary dependencies
echo -e "${LIGHT_BLUE}Updating and upgrading system packages...${RESET}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl wget git nano jq

# Install Docker
echo -e "${LIGHT_BLUE}Installing Docker...${RESET}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
docker version

# Install Docker Compose
echo -e "${LIGHT_BLUE}Installing Docker Compose...${RESET}"
VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Add user to Docker group
echo -e "${LIGHT_BLUE}Adding current user to the Docker group...${RESET}"
sudo groupadd docker
sudo usermod -aG docker $USER

# Clone the repository
echo -e "${LIGHT_BLUE}Cloning Allora Chain repository...${RESET}"
git clone -b main https://github.com/allora-network/allora-chain.git

# Navigate to the cloned directory
cd allora-chain

# Replace requirements.txt with docker-compose.yaml
echo -e "${LIGHT_BLUE}Replace with the new docker-compose.yaml...${RESET}"
rm -rf docker-compose.yaml
wget -q https://raw.githubusercontent.com/0xtnpxsgt/Allora-Full-Node-Setup/main/docker-compose.yaml -O /root/allora-chain/docker-compose.yaml

# Pull and start Docker containers
echo -e "${LIGHT_BLUE}Pulling Docker images and starting containers...${RESET}"
docker compose pull
docker compose up -d

echo -e "${BRIGHT_GREEN}Installation complete!${RESET}"
echo -e "Run ${BOLD}docker compose logs -f${RESET} to check logs."