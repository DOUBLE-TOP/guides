#!/usr/bin/env bash
echo "рџ†™ Starting Availup..."
index=0 # Установка значения по умолчанию для индекса.

while [ $# -gt 0 ]; do
    if [[ $1 = "--index" ]]; then
        index="$2" # Изменение: присваиваем переменной index значение аргумента, следующего за --index.
        shift
    else
        if [[ $1 = "--"* ]]; then
            v="${1/--/}"
            declare "$v"="$2"
            shift
        fi
    fi
    shift
done
# generate folders if missing
if [ ! -d "$HOME/.avail$i" ]; then
    mkdir $HOME/.avail$i
fi
if [ ! -d "$HOME/.avail$i/bin" ]; then
    mkdir $HOME/.avail$i/bin
fi
if [ ! -d "$HOME/.avail$i/identity" ]; then
    mkdir $HOME/.avail$i/identity
fi
if [ ! -d "$HOME/.avail$i/data" ]; then
    mkdir $HOME/.avail$i/data
fi
if [ ! -d "$HOME/.avail$i/config" ]; then
    mkdir $HOME/.avail$i/config
fi
# check if bash is current terminal shell, else check for zsh
if [ -z "$BASH_VERSION" ]; then
    if [ -z "$ZSH_VERSION" ]; then
        echo "рџљ« Unable to locate a shell. Availup might not work as intended!"
    else
        CURRENT_TERM="zsh"
    fi
else
    CURRENT_TERM="bash"
fi
if [ "$CURRENT_TERM" = "bash" -a -f "$HOME/.bashrc" ]; then
    PROFILE="$HOME/.bashrc"
elif [ "$CURRENT_TERM" = "bash" -a -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
elif [ "$CURRENT_TERM" = "bash" -a -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
elif [ "$CURRENT_TERM" = "bash" -a -f "$HOME/.zsh_profile" ]; then
    PROFILE="$HOME/.zsh_profile"
elif [ "$CURRENT_TERM" = "zsh" -a -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
elif [ "$CURRENT_TERM" = "zsh" -a -f "$HOME/.zsh_profile" ]; then
    PROFILE="$HOME/.zsh_profile"
elif [ "$CURRENT_TERM" = "bash" ]; then
    PROFILE="$HOME/.bashrc"
    touch $HOME/.bashrc
elif [ "$CURRENT_TERM" = "zsh" ]; then
    PROFILE="$HOME/.zshrc"
    touch $HOME/.zshrc
else
    echo "рџ«Ј Unable to locate a compatible shell or rc file, using POSIX default, availup might not work as intended!"
    PROFILE="/etc/profile"
fi
if [ -z "$network" ]; then
    echo "рџ›њ  No network selected. Defaulting to goldberg testnet."
    NETWORK="goldberg"
else
    NETWORK="$network"
fi
CONFIG_PARAMS="bootstraps=['/dns/bootnode.1.lightclient.goldberg.avail.tools/tcp/37000/p2p/12D3KooWBkLsNGaD3SpMaRWtAmWVuiZg1afdNSPbtJ8M8r9ArGRT','/dns/bootnode.2.lightclient.goldberg.avail.tools/tcp/37000/p2p/12D3KooWRCgfvaLSnQfkwGehrhSNpY7i5RenWKL2ARst6ZqgdZZd']\nfull_node_ws=['wss://rpc-goldberg.sandbox.avail.tools:443','wss://goldberg-rpc.fra.avail.tools:443']\nconfidence=99.0\navail_path='$HOME/.avail$i/data'\nkad_record_ttl=43200\not_collector_endpoint='http://otelcol.lightclient.goldberg.avail.tools:4317'\ngenesis_hash='6f09966420b2608d1947ccfb0f2a362450d1fc7fd902c29b67c906eaa965a7ae'\n"
AVAIL_BIN=$HOME/.avail$i/bin/avail-light
if [ "$NETWORK" = "goldberg" ]; then
    echo "рџ“Њ Goldberg testnet selected."
    VERSION="v1.7.10"
    if [ -z "$config" ]; then
        CONFIG="$HOME/.avail$i/config/config.yml"
        if [ -f "$CONFIG" ]; then
            echo "рџ—‘пёЏ  Wiping old config file at $CONFIG."
            rm $CONFIG
        else
            echo "рџ¤· No configuration file set. This will be automatically generated at startup."
        fi
        touch $CONFIG
        echo -e $CONFIG_PARAMS >>$CONFIG
    else
        CONFIG="$config"
    fi
elif [ "$NETWORK" = "local" ]; then
    echo "рџ“Њ Local testnet selected."
    VERSION="v1.7.10"
    if [ -z "$config" ]; then
        echo "рџљ« No configuration file was provided for local testnet, exiting."
        exit 1
    fi
else
    echo "рџљ« Invalid network selected. Select one of the following: goldberg, local."
    exit 1
fi
if [ -z "$app_id" ]; then
    echo "рџ“І No app ID specified. Defaulting to light client mode."
    APPID="0"
else
    APPID="$app_id"
fi
if [ -z "$identity" ]; then
    IDENTITY=$HOME/.avail$i/identity/identity.toml
    if [ -f "$IDENTITY" ]; then
        echo "рџ”‘ Identity found at $IDENTITY."
    else
        echo "рџ¤· No identity set. This will be automatically generated at startup."
    fi
else
    IDENTITY="$identity"
fi
# check if avail-light version matches!
UPGRADE=0
if [ ! -z "$upgrade" ]; then
    echo "рџ”„ Checking for updates..."
    if [ -f $AVAIL_BIN ]; then
        CURRENT_VERSION="v$($HOME/.avail$i/bin/avail-light --version | cut -d " " -f 2)"
        if [ "$CURRENT_VERSION" = "v1.7.9" ]; then
            UPGRADE=1
            echo "в¬†пёЏ  Avail binary is out of date. Upgrading..."
        elif [ "$CURRENT_VERSION" != "$VERSION" ]; then
            UPGRADE=1
            echo "в¬†пёЏ  Avail binary is out of date. Upgrading..."
        else
            echo "вњ… Avail binary is up to date."
            if [ "$upgrade" = "y" -o "$upgrade" = "yes" ]; then
                UPGRADE=1
            fi
        fi
    fi
else 
    if [ -f $AVAIL_BIN ]; then
        CURRENT_VERSION="v$($HOME/.avail$i/bin/avail-light --version | cut -d " " -f 2)"
        if [ "$CURRENT_VERSION" = "v1.7.9" ]; then
            UPGRADE=1
            echo "в¬†пёЏ  Avail binary is out of date. Upgrading..."
        fi
    fi
fi

onexit() {
    chmod 600 $IDENTITY
    echo "рџ”„ Avail stopped. Future instances of the light client can be started by invoking the avail-light binary or rerunning this script$EXTRAPROMPT"
    if [[ ":$PATH:" != *":$HOME/.avail$i/bin:"* ]]; then
        if ! grep -q "export PATH=\"\$PATH:$HOME/.avail$i/bin\"" "$PROFILE"; then
            echo -e "export PATH=\"\$PATH:$HOME/.avail$i/bin\"\n" >>$PROFILE
        fi
        echo -e "рџ“Њ Avail has been added to your profile. Run the following command to load it in the current session:\n. $PROFILE\n"
    fi
    exit 0
}
# check if avail-light binary is available and check if upgrade variable is set to 0
if [ -f $AVAIL_BIN -a "$UPGRADE" = 0 ]; then
    echo "вњ… Avail is already installed. Starting Avail..."
    trap onexit EXIT
    $AVAIL_BIN --config $CONFIG --app-id $APPID --identity $IDENTITY
    exit 0
fi
if [ "$UPGRADE" = 1 ]; then
    echo "рџ”„ Resetting configuration and data..."
    if [ -f $AVAIL_BIN ]; then
        rm $AVAIL_BIN
        if [ -f $CONFIG ]; then
            rm $CONFIG
            touch $CONFIG
            echo -e $CONFIG_PARAMS >>$CONFIG
        fi
        if [ -d "$HOME/.avail$i/data" ]; then
            rm -rf $HOME/.avail$i/data
            mkdir $HOME/.avail$i/data
        fi
    else
        echo "рџ¤” Avail was not installed with availup. Attemping to uninstall with cargo..."
        cargo uninstall avail-light || echo "рџ‘Ђ Avail was not installed with cargo, upgrade might not be required!"
        if command -v avail-light >/dev/null 2>&1; then
            echo "рџљ« Avail was not uninstalled. Please uninstall manually and try again."
            exit 1
        fi
    fi
fi
if [ "$(uname -m)" = "arm64" -a "$(uname -s)" = "Darwin" ]; then
    ARCH_STRING="apple-arm64"
elif [ "$(uname -m)" = "x86_64" -a "$(uname -s)" = "Darwin" ]; then
    ARCH_STRING="apple-x86_64"
elif [ "$(uname -m)" = "aarch64" -o "$(uname -m)" = "arm64" ]; then
    ARCH_STRING="linux-arm64"
elif [ "$(uname -m)" = "x86_64" ]; then
    ARCH_STRING="linux-amd64"
fi
if [ -z "$ARCH_STRING" ]; then
    echo "рџ“Ґ No binary available for this architecture, building from source instead. This can take a while..."
    # check if cargo is not available, else attempt to install through rustup
    if command -v cargo >/dev/null 2>&1; then
        echo "рџ“¦ Cargo is available. Building from source..."
    else
        echo "рџ‘Ђ Cargo is not available. Attempting to install with Rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        EXTRAPROMPT="\nв„№пёЏ Cargo env needs to be loaded by running source \$HOME/.cargo/env"
        echo "рџ“¦ Cargo is now available. Reattempting to build from source..."
    fi
    # check if avail-light folder exists in home directory, if yes, pull latest changes, else clone the repo
    AVAIL_LIGHT_DIR=$HOME/avail-light
    if [ -d $AVAIL_LIGHT_DIR ]; then
        echo "рџ”„ Updating avail-light repository and building..."
        cd $AVAIL_LIGHT_DIR
        git pull -q origin $VERSION
        git checkout -q $VERSION
        cargo build --release
        cp $AVAIL_LIGHT_DIR/target/release/avail-light $AVAIL_BIN
    else
        echo "рџ“‚ Cloning avail-light repository and building..."
        git clone -q -c advice.detachedHead=false --depth=1 --single-branch --branch $VERSION https://github.com/availproject/avail-light.git $AVAIL_LIGHT_DIR
        cd $AVAIL_LIGHT_DIR
        cargo build --release
        mv $AVAIL_LIGHT_DIR/target/release/avail-light $AVAIL_BIN
        rm -rf $AVAIL_LIGHT_DIR
    fi
else
    if command -v curl >/dev/null 2>&1; then
        curl -sLO https://github.com/availproject/avail-light/releases/download/$VERSION/avail-light-$ARCH_STRING.tar.gz
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://github.com/availproject/avail-light/releases/download/$VERSION/avail-light-$ARCH_STRING.tar.gz
    else
        echo "рџљ« Neither curl nor wget are available. Please install one of these and try again."
        exit 1
    fi
    # use tar to extract the downloaded file and move it to .avail/bin/ directory
    tar -xzf avail-light-$ARCH_STRING.tar.gz
    chmod +x avail-light-$ARCH_STRING
    mv avail-light-$ARCH_STRING $AVAIL_BIN
    rm avail-light-$ARCH_STRING.tar.gz
fi
echo "вњ… Availup exited successfully."
echo "рџ§± Starting Avail."
trap onexit EXIT
$AVAIL_BIN --config $CONFIG --app-id $APPID --identity $IDENTITY