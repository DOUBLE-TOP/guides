#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Бекап Andes тестнета"
echo "-----------------------------------------------------------------------------"

sudo systemctl stop dill &>/dev/null

cd $HOME
mkdir -p dill_backups
mkdir -p dill_backups/andes

cp -r $HOME/dill/keystore $HOME/dill_backups/andes/keystore &>/dev/null
cp -r $HOME/dill/validator_keys $HOME/dill_backups/andes/validator_keys &>/dev/null
cp $HOME/dill/walletPw.txt $HOME/dill_backups/andes/walletPw.txt &>/dev/null
cp $HOME/dill/validators.json $HOME/dill_backups/andes/validators.json &>/dev/null

sudo systemctl disable dill &>/dev/null
sudo systemctl daemon-reload &>/dev/null

rm -rf $HOME/dill
rm -f /etc/systemd/system/dill.service

echo "-----------------------------------------------------------------------------"
echo "Миграция для Ваку"
echo "-----------------------------------------------------------------------------"

if ss -tuln | grep -q ":4000"; then
  docker compose -f $HOME/nwaku-compose/docker-compose.yml down
  sed -i 's/127\.0\.0\.1:4000:4000/0.0.0.0:4044:4000/g' $HOME/nwaku-compose/docker-compose.yml
  docker compose -f $HOME/nwaku-compose/docker-compose.yml up -d
else
  echo "Порт 4000 свободен."
fi

echo "-----------------------------------------------------------------------------"
echo "Установка Dill Alps ноды"
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -O https://dill-release.s3.ap-southeast-1.amazonaws.com/v1.0.3/dill-v1.0.3-linux-amd64.tar.gz
tar -xzvf dill-v1.0.3-linux-amd64.tar.gz && rm -rf dill-v1.0.3-linux-amd64.tar.gz

sed -i 's|monitoring-port  9080 tcp|monitoring-port  8380 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-http.port 8545 tcp|exec-http.port 8945 tcp|' "$HOME/dill/default_ports.txt"
sed -i 's|exec-port 30303 tcp&&udp|exec-port 30305 tcp&&udp|' "$HOME/dill/default_ports.txt"

cd $HOME/dill

# Define variables
DILL_DIR="$(pwd)"
KEYS_DIR="$DILL_DIR/validator_keys"
KEYSTORE_DIR="$DILL_DIR/keystore"
PASSWORD_FILE="$KEYS_DIR/keystore_password.txt"

echo ""
echo "********** Step 1: Generating Validator Keys **********"
echo ""

echo "Validator Keys are generated from a mnemonic"
mnemonic=""
timestamp=$(date +%s)
mnemonic_path="$DILL_DIR/validator_keys/mnemonic-$timestamp.txt"
cd $DILL_DIR

while true; do
    read -p "Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]: " mne_src
    mne_src=${mne_src:-1}  # Set default choice to 1
    case "$mne_src" in
        "1" | "new")
            ./dill_validators_gen generate-mnemonic --mnemonic_path $mnemonic_path
            ret=$?
            if [ $ret -ne 0 ]; then
                echo "dill_validators_gen generate-mnemonic failed"
                exit 1
            fi
            mnemonic="$(cat $mnemonic_path)"

            break
            ;;
        "2" | "existing")
            read -p "Enter your existing mnemonic: " existing_mnemonic
            if [[ $existing_mnemonic =~ ^([a-zA-Z]+[[:space:]]+){11,}[a-zA-Z]+$ ]]; then
                mnemonic="$existing_mnemonic"
                break
            else
                echo ""
                echo "[Error]Invalid mnemonic format. A valid mnemonic should consist of 12 or more space-separated words."
            fi
            ;;
        *)
            echo ""
            echo "[Error] $mne_src is not a valid mnemonic source option"
            ;;
    esac
done

# wait enter password
password=""
echo ""
echo "Generate a random password that secures your validator keystore(s)."
password=$(openssl rand -base64 12)  # Generate a random password
echo ""
echo "Generated password: $password"
echo ""
echo "The password will be saved to $PASSWORD_FILE. Press any key to continue..."
read -n 1 -s -r
echo ""  # Move to a new line after the key press
[ ! -d "$KEYS_DIR" ] && mkdir -p "$KEYS_DIR"
echo $password > $PASSWORD_FILE

while true; do
    read -p "Please choose an option for deposit token amount [1, 3600, 2, 36000] [1]: " deposit_option
    deposit_option=${deposit_option:-1}  # Set default choice to 1
    case "$deposit_option" in
        "1" | "3600")
            deposit_amount=3600
            break
            ;;
        "2" | "36000")
            deposit_amount=36000
            break
            ;;
        *)
            echo ""
            echo "[Error] $deposit_option is not a valid option for deposit token amount"
            ;;
    esac
done

while true; do
    read -p "Please enter your withdrawal address: " with_addr
    if ! [[ $with_addr =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "Invalid Ethereum execution address format. It should start with '0x' followed by 40 hexadecimal characters."
    else 
        break
    fi
done

# Generate validator keys
./dill_validators_gen existing-mnemonic --mnemonic="$mnemonic" --validator_start_index=0 --num_validators=1 --chain=alps --deposit_amount=$deposit_amount --keystore_password="$password" --execution_address="$with_addr"
ret=$?
if [ $ret -ne 0 ]; then
    echo "dill_validators_gen existing-mnemonic failed"
    exit 1
fi

echo ""
echo "********** Step 2: Import keys and start dill-node **********"
echo ""

# Import your keys to your keystore
echo "Importing keys to keystore..."
./dill-node accounts import --alps --wallet-dir $KEYSTORE_DIR --keys-dir $KEYS_DIR --accept-terms-of-use --account-password-file $PASSWORD_FILE --wallet-password-file $PASSWORD_FILE


TEMP=$(getopt -o 'k:n:p:' --long 'keydir:,natIP:,pwdfile:' -n 'example.bash' -- "$@")
if [ $? -ne 0 ]; then
        echo 'Terminating...' >&2
        exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

NODE_BIN="dill-node"
NAT_IP=""
PEER_ENR=""
PEER_ID=""
KEY_DIR="$PJROOT/keystore"
KEY_PWD_FILE=""


if [ -z "$KEY_PWD_FILE" ];then
    KEY_PWD_FILE="$PJROOT/validator_keys/keystore_password.txt"    
    if [ ! -f "$KEY_PWD_FILE" ]; then
        KEY_PWD_FILE="$PJROOT/walletPw.txt"
        if [ ! -f "$KEY_PWD_FILE" ]; then
            echo "cannot find file: $PJROOT/validator_keys/keystore_password.txt, please make sure it exists and is a file with your password inside"
            exit 1
        fi
    fi
fi

LIGHT_PROC_ROOT=$PJROOT/light_node
FULL_PROC_ROOT=$PJROOT/full_node
has_light=0
has_full=0
if [ -d $LIGHT_PROC_ROOT ];then
    has_light=1
fi
if [ -d $FULL_PROC_ROOT ];then
    has_full=1
fi
if [ $has_light -eq 1 ] && [ $has_full -eq 1 ]; then
    echo "Error: Both light_node and full_node directories exist. Please ensure only one of them is present."
    exit 1
fi
if [ $has_light -eq 0 ] && [ $has_full -eq 0 ]; then
    echo "Error: Neither light_node nor full_node directory exists. Please ensure one of them is present."
    exit 1
fi

if [ $has_light -eq 1 ];then
    PROC_ROOT=$PJROOT/light_node
else
    PROC_ROOT=$PJROOT/full_node
fi
DATA_ROOT=$PROC_ROOT/data
LOG_ROOT=$PROC_ROOT/logs

default_port_file="default_ports.txt"

PORT_FLAGS=""
port_occupied=""
declare -A ports_used
while read line; do
    kv=($line)
    flag=${kv[0]}
    port=${kv[1]}
    protocol=${kv[2]}
    for ((i=0; i<1000; i++)); do
        port_start=$port
        if [[ ${ports_used[$port]} -eq 1 ]]; then
            port=$(($port+1))
            continue
        fi

        if [ "$protocol" == "udp" ]; then
            lsof -iUDP:$port -n -P > /dev/null
        elif [ "$protocol" == "tcp" ]; then
            lsof -iTCP:$port -n -P -s tcp:listen > /dev/null
        else
            lsof -iTCP:$port -n -P -s tcp:listen > /dev/null || lsof -iUDP:$port -n -P > /dev/null
        fi
        if [ $? -eq 0 ]; then
            tlog "$protocol port $port occupied, try port $(($port+1))"
            port=$(($port+1))
            port_occupied="yes"
        else 
            port_occupied=""
            break
        fi
    done
    if [ ! -z "$port_occupied" ]; then
        echo "after try 1000 times, no available ports [$port_start, $port] found, exit"
        exit 1
    fi
    PORT_FLAGS="$PORT_FLAGS --$flag $port"
    ports_used[$port]=1
done < $default_port_file

echo "using password file at $KEY_PWD_FILE"


ensure_path(){
    path=$1
    if [ ! -d $path ]; then
        mkdir -p $path
    fi
}

if [ ! -z "$NAT_IP" ]; then
    DISCOVERY_FLAGS="--exec-nat extip:$NAT_IP --p2p-host-ip $NAT_IP"
fi

VALIDATOR_FLAGS="--embedded-validator --validator-datadir $DATA_ROOT/validatordata --wallet-password-file $KEY_PWD_FILE "

if [ ! -z "$KEY_DIR" ]; then
    VALIDATOR_FLAGS="$VALIDATOR_FLAGS --wallet-dir $KEY_DIR "
fi

COMMON_FLAGS="--light --datadir $DATA_ROOT/beacondata \
--genesis-state $PJROOT/genesis.ssz --grpc-gateway-host 0.0.0.0 --initial-validators $PJROOT/validators.json \
--block-batch-limit 128 --min-sync-peers 1 --minimum-peers-per-subnet 1 \
--alps --enable-debug-rpc-endpoints \
--suggested-fee-recipient 0x1a5E568E5b26A95526f469E8d9AC6d1C30432B33 \
--log-format json --verbosity error --log-file $LOG_ROOT/dill.log \
--exec-http --exec-http.api eth,net,web3 --exec-gcmode archive --exec-syncmode full --exec-mine=false --accept-terms-of-use "

sudo tee /etc/systemd/system/dill.service > /dev/null << EOF
[Unit]
Description=Dill Light Node
After=network-online.target

[Service]
User=$USER
ExecStart=$PJROOT/$NODE_BIN $COMMON_FLAGS $DISCOVERY_FLAGS $VALIDATOR_FLAGS $PORT_FLAGS
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable dill.service
sudo systemctl start dill

echo "start light node done"

sleep 3

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"