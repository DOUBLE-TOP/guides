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

# Constants
kbPerGb=1000000

# Date
dateRuntime=$(date '+%Y%m%d%H%M%S')

# Defaults
defaultName="lightning"
defaultDockerImageName="$defaultName"
defaultDockerContainerName="$defaultName-node"
defaultDockerRegistryUrl="ghcr.io/fleek-network/lightning"
defaultDockerRegistryTag="latest"
defaultDockerRegistryName="$defaultDockerRegistryUrl:$defaultDockerRegistryTag"
defaultLightningPath="$HOME/fleek-network/$defaultName"
defaultLightningLogPath="/var/log/$defaultName"
defaultLightningDiagnosticFilename="diagnostic.log"
defaultLightningOutputFilename="output.log"
defaultLightningDiagnosticLogAbsPath="$defaultLightningLogPath/$defaultLightningDiagnosticFilename"
defaultLightningOutputLogAbsPath="$defaultLightningLogPath/$defaultLightningOutputFilename"
defaultLightningSystemdServiceName="docker-$defaultName"
defaultLightningSystemdServicePath="/etc/systemd/system/$defaultLightningSystemdServiceName.service"
defaultLightningBasePath="$HOME/.$defaultName"
defaultDiscordUrl="https://discord.gg/fleekxyz"
defaultDocsSite="https://docs.fleek.network"
defaultMinMemoryKBytesRequired=32000000
defaultMinDiskSpaceKBytesRequired=20000000
defaultDockerDaemonJson="/etc/docker/daemon.json"
defaultPortRangeTCPStart=4200
defaultPortRangeTCPEnd=4299
defaultPortRangeUDPStart=4300
defaultPortRangeUDPEnd=4399
defaultPortRangeTCP="$defaultPortRangeTCPStart-$defaultPortRangeTCPStart"
defaultPortRangeUDP="$defaultPortRangeUDPStart-$defaultPortRangeUDPEnd"

# App state
vCPUs=$(nproc --all)
selectedLightningPath="$defaultLightningPath"
vCPUsMinusOne=$(($vCPUs - 1))

# Error codes
err_non_root=87

# Utils
checkSystemHasRecommendedResources() {
  mem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo);
  partDiskSpace=$(df --output=avail -B 1 "$PWD" |tail -n 1)

  if [[ ("$mem" -lt "$defaultMinMemoryKBytesRequired") ]] || [[ ( "$partDiskSpace" -lt "$defaultMinDiskSpaceKBytesRequired" ) ]]; then
    echo "😬 Oh no! You need to have at least $((defaultMinMemoryKBytesRequired / kbPerGb))GB of RAM and $((defaultMinDiskSpaceKBytesRequired / kbPerGb))GB of available disk space."
    echo
    printf -v prompt "\n\n🤖 Are you sure you want to continue (yes/no)?"
    read -r -p "$prompt"$'\n> ' answer

    if [[ "$answer" == [nN] || "$answer" == [nN][oO] ]]; then
      printf "🦖 Exited the installation process\n\n"

      exit 1
    fi

    echo "😅 Alright, let's try that, but your system is below our recommendations, so don't expect it to work correctly..."

    sleep 5

    return 0
  fi
  
  echo "👍 Great! Your system has enough resources (disk space and memory)"
}

identifyOS() {
  unameOut="$(uname -s)"

  case "${unameOut}" in
      Linux*)     os=Linux;;
      Darwin*)    os=Mac;;
      CYGWIN*)    os=Cygwin;;
      MINGW*)     os=MinGw;;
      *)          os="UNKNOWN:${unameOut}"
  esac

  echo "$os" | tr '[:upper:]' '[:lower:]'
}

identifyDistro() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "$ID"

    exit 0
  fi
  
  uname
}

isOSSupported() {
  os=$(identifyOS)

  if [[ "$os" == "linux" ]]; then
    distro=$(identifyDistro)

    if [[ "$distro" == "ubuntu" ]]; then
      currVersion=$(lsb_release -r -s | tr -d '.')

      if [[ "$currVersion" -lt "2204" ]]; then
        echo
        echo "👹 Oops! You'll need Ubuntu 22.04 at least"
        echo

        exit 1
      fi
    elif [[ "$distro" == "debian" ]]; then
      currVersion=$(lsb_release -r -s | tr -d '.')

      if [[ "$currVersion" -lt "11" ]]; then
        echo
        echo "👹 Oops! You'll need Debian 11 at least"
        echo

        exit 1
      fi
    else
      printf "👹 Oops! Your operating system (%) distro (%s) is not supported by the installer at this time. Check our guides to learn how to install on your own %s\n" "$os" "$distro" "$defaultDocsSite"

      exit 1    
    fi

    echo "✅ Operating system ($os), distro ($distro) is supported!"
  else
    printf "👹 Oops! Your operating system (%) is not supported by the installer at this time. Check our guides to learn how to install on your own %s\n" "$os" "$defaultDocsSite"

    exit 1
  fi
}

hasCommand() {
  command -v "$1" >/dev/null 2>&1
}

exitInstaller() {
  exit 1;
}

checkIfDockerInstalled() {
  if ! hasCommand docker; then
    printf "👹 Oops! Docker is required and was not found!\n"

    installDocker

    if [[ "$?" = 1 ]]; then
      printf "👹 Oops! Failed to install docker.\n"

      exitInstaller
    fi
  fi

  printf "✅ Docker is installed!\n"
}

installDocker() {
  os=$(identifyOS)

  if [[ "$os" == "linux" ]]; then
    distro=$(identifyDistro)

    if [[ "$distro" == "ubuntu" ]]; then
      sudo apt-get update
      sudo DEBIAN_FRONTEND=noninteractive apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        -yq

      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

      sudo apt-get update

      sudo DEBIAN_FRONTEND=noninteractive apt-get install \
          docker-ce \
          docker-ce-cli \
          containerd.io \
          docker-compose-plugin \
          -yq
    elif [[ "$distro" == "debian" ]]; then
      sudo apt-get update
      sudo DEBIAN_FRONTEND=noninteractive apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        dnsutils \
        docker-compose-plugin \
        -yq

      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

      sudo apt-get update

      sudo DEBIAN_FRONTEND=noninteractive apt-get install \
          docker-ce \
          docker-ce-cli \
          containerd.io \
          -yq
    else
      echo "👹 Oops! Your Linux distro is not supported yet by our install script."

      exitInstaller
    fi
  else
    echo "👹 Oops! Your Linux distro is not supported yet by our install script."

    exitInstaller
  fi
}

hasFreePortRange() {
  hasUsedPort=0
  portStart=$1
  portEnd=$2

  for (( port=portStart; port <= portEnd; port++ )); do
    if lsof -i :"$port" >/dev/null; then
      echo "💩 Uh-oh! The port $port is required but is in use" >&2

      hasUsedPort=1
    fi
  done

  echo "$hasUsedPort"
}

(
  exec < /dev/tty;

  # TODO: Check CPU architecture if x64 `GenuineIntel`, otherwise throw warning

  # 🚑 Check if running in Bash and supported version
  [ "$BASH" ] || { printf >&2 '🙏 Run the script with Bash, please!\n'; exit 1; }
  (( BASH_VERSINFO[0] > 4 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2 )) || { printf >&2 '🙏 Bash 4.2 or newer is required!\n'; exit 1; }

  # 🚑 Check total Processing Units
  defaultMinCPUUnitsCount=2
  vCPUs=$(nproc --all)
  if [[ "$vCPUs" -lt "$defaultMinCPUUnitsCount" ]]; then
    while read -rp "😅 The installer needs at least $defaultMinCPUUnitsCount total processing units, your system has $vCPUs. The installer is likely to fail, would you like to continue? (yes/no)" answer; do
      if [[ "$answer" == [nN] || "$answer" == [nN][oO] ]]; then
        printf "🦖 Exited the installation process\n\n"

        exit 1
      elif [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]; then
        printf "😅 Good luck!\n\n"

        break;
      fi

      printf "💩 Uh-oh! We expect a yes or no answer. Try again...\n"
    done
  fi

  echo

  # Check if system has recommended resources (disk space and memory)
#   checkSystemHasRecommendedResources "$os"

  # Warning for root users
  if [[ "$EUID" -eq 0 ]]; then
    echo "⚠️ WARNING: You're running the installer as ROOT user which is not recommended due to risks it poses to the system security. Create a sudo account, which allows you to execute commands with root privileges without logging in as root. Check our documentation to learn how to create a new user $defaultDocsSite/docs/node/Install and try again later, please!"

    exit 1
  fi

  # 🚑 Check if ports available
  if ! hasCommand lsof; then
    printf "🤖 Install lsof for installer port verification\n"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install lsof -yq
  fi

  hasTCPPortsAvailable=$(hasFreePortRange "$defaultPortRangeTCPStart" "$defaultPortRangeTCPEnd")
  hasUDPPortsAvailable=$(hasFreePortRange "$defaultPortRangeUDPStart" "$defaultPortRangeUDPEnd")

  if [[ "$hasTCPPortsAvailable" -eq 1 || "$hasUDPPortsAvailable" -eq 1 ]]; then
    echo "👹 Oops! Required port(s) are in use, make sure the ports are freed before retrying, please! To learn more about required ports https://docs.fleek.network/docs/node/requirements"

    exit 1
  fi

  # Check if user is sudoer, as the command uses `sudo` warn the user
  if ! groups | grep -q 'root\|sudo'; then
    printf "⛔️ Attention! You need to have admin privileges (sudo), switch user and try again please! 🙏\n" >&2;

    exit "$err_non_root";
  fi

  checkIfDockerInstalled

  # Create the directory to bound
  if [[ ! -d "$defaultLightningBasePath" ]]; then
    if ! sudo mkdir -p "$defaultLightningBasePath"; then
      echo "👹 Oops! Failed to create the directory $defaultLightningBasePath"

      exit 1
    fi

    if ! sudo chown "$(whoami):$(whoami)" "$defaultLightningBasePath"; then
      echo "👹 Oops! Failed to change owner of the directory $defaultLightningBasePath"
    else
      echo "✅ Updated ownership of the directory $defaultLightningBasePath to $(whoami)"
    fi
  else
    echo "✅ The Lightning $defaultLightningBasePath exists"
  fi

  printf "🤖 Create the %s log directory %s\n" "$defaultName" "$defaultLightningLogPath"
  if ! sudo mkdir -p "$defaultLightningLogPath"; then
    printf "💩 Uh-oh! Failed to create the %s system log dir %s for some reason...\n" "$defaultName" "$defaultLightningLogPath"
  else
    if ! sudo chown "$(whoami):$(whoami)" "$defaultLightningLogPath"; then
      printf "💩 Uh-oh! Failed to chown %s\n" "$defaultLightningLogPath"
    fi
  fi

  echo "📒 Clear logs"
  for file in "$defaultLightningDiagnosticLogAbsPath" "$defaultLightningOutputLogAbsPath"; do
    if [[ -f "$file" ]] && ! sudo rm "$file"; then
      echo "👹 Oops! Failed to remove $file"
    fi
  done

# Important: the LIGHTNING_SERVICE it does not have identation on purpose, do not change
echo "
[Unit]
Description=Fleek Network Node lightning service
After=docker.service
Requires=docker.service
 
[Service]
Restart=always
RestartSec=5
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill $defaultDockerContainerName
ExecStartPre=-/usr/bin/docker rm $defaultDockerContainerName
ExecStartPre=/usr/bin/docker pull $defaultDockerRegistryUrl:$defaultDockerRegistryTag
ExecStart=/usr/bin/docker run \
  -p 4230:4230 \
  -p 4200:4200 \
  -p 6969:6969 \
  -p 18000:18000 \
  -p 18101:18101 \
  -p 18102:18102 \
  --mount type=bind,source=$defaultLightningBasePath,target=/root/.$defaultName \
  --mount type=bind,source=/var/tmp,target=/var/tmp \
  --name $defaultDockerContainerName \
  $defaultDockerRegistryName
ExecStop=/usr/bin/docker stop
StandardOutput=append:$defaultLightningOutputLogAbsPath
StandardError=append:$defaultLightningDiagnosticLogAbsPath

[Install]
WantedBy=multi-user.target
" | sudo tee "$defaultLightningSystemdServicePath" > /dev/null

  printf "🤖 Set service file permissions\n"
  sudo chmod 644 "$defaultLightningSystemdServicePath"

  printf "🤖 System control daemon reload\n"
  sudo systemctl daemon-reload

  printf "🤖 Enable %s service on startup when the system boots\n" "$defaultLightningSystemdServiceName"
  sudo systemctl enable "$defaultLightningSystemdServiceName"

  echo
  echo

  echo "🤖 Launch or stop the Network Node by running:"
  echo "sudo systemctl start $defaultLightningSystemdServiceName"
  echo "sudo systemctl stop $defaultLightningSystemdServiceName"
  echo "sudo systemctl restart $defaultLightningSystemdServiceName"
  echo
  echo "🎛️ Check the status of the service:"
  echo "sudo systemctl status $defaultLightningSystemdServiceName"
  echo
  echo "👀 You can watch the Node output by running the command:"
  echo "tail -f $defaultLightningOutputLogAbsPath"
  echo
  echo "🥼 For diagnostics run the command:"
  echo "tail -f $defaultLightningDiagnosticLogAbsPath"
  echo
  echo "Learn more by checking our guides at $defaultDocsSite"
  echo "✨ That's all!"
  echo
)