#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Удаление Sonaric Node"
echo "-----------------------------------------------------------------------------"

DEVNULL="/dev/null"
SONARIC_ARGS=""

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

print_message() {
  tput bold
  echo ""
	echo "$@"
	echo ""
  tput sgr0
}

exec_cmd() {
  if [ "$VERBOSE" = true ]; then
    echo "$@"
  fi
  $sh_c "$@"
}

confirm_Y() {
  read -p "$1 [Y/n] " reply;
  if [ "$reply" = "${reply#[Nn]}" ]; then
    return 0
  fi
 return 1
}

# stop and delete all workloads
if ! command_exists sonaric; then
    echo "Sonaric installation is not found"
    exit 0
fi

confirm_Y "Do you really want to uninstall Sonaric?" || exit 0

# check if systemctl unit is present and if it is active
if command_exists systemctl && systemctl list-units --full --all sonaricd.service | grep -Fq 'loaded'; then
    exec_cmd "systemctl start sonaricd > $DEVNULL"
fi

# stop and delete all workloads
if command_exists sonaric; then
    exec_cmd "systemctl start sonaricd"
    for try in $(seq 1 20); do
        exec_cmd "sonaric version > $DEVNULL 2>&1" && break || sleep 2
    done
    print_message "Preparing to remove Sonaric..."
    confirm_Y "Do you want to export your Sonaric identity?" && exec_cmd "sonaric identity-export"
    print_message "Removing workloads..."
    exec_cmd "sonaric stop $SONARIC_ARGS -a > $DEVNULL 2>&1"
    exec_cmd "sonaric delete $SONARIC_ARGS -a --force > $DEVNULL 2>&1"
fi

print_message "Removing installed packages..."

# Run setup for each distro accordingly
case "$lsb_dist" in
    ubuntu|debian|raspbian)
        exec_cmd "DEBIAN_FRONTEND=noninteractive apt-get remove --auto-remove -y -qq sonaricd > $DEVNULL"
        exec_cmd "rm -f /etc/apt/sources.list.d/sonaric.list"
        exec_cmd "rm -f /etc/apt/keyrings/sonaric.gpg"
    echo "Done"
        exit 0
        ;;
    centos|fedora|rhel|rocky)
        # use dnf for fedora or rocky linux, yum for centos or rhel
        if [ "$lsb_dist" = "fedora" ] || [ "$lsb_dist" = "rocky" ]; then
            pkg_manager="dnf"
    elif [ "$lsb_dist" = "centos" ]; then
            pkg_manager="yum"
        fi

    exec_cmd "$pkg_manager remove -y -q sonaricd sonaric > $DEVNULL 2>&1"
    exec_cmd "rm -f /etc/yum.repos.d/artifact-registry.repo"
    echo "Done"
        exit 0
        ;;
    *)
        echo
        echo "ERROR: Unsupported distribution '$lsb_dist'"
        echo
        exit 1
        ;;
esac
exit 1
