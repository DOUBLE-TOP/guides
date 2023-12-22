#!/bin/bash
# Default variables
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
sudo apt update &> /dev/null
#go
cd $HOME
! [ -x "$(command -v go)" ] && {
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz" &> /dev/null
sudo rm -rf /usr/local/go &> /dev/null
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz" &> /dev/null
rm "go$VER.linux-amd64.tar.gz" &> /dev/null
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
}
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
sleep 2
#clone rp
git clone https://github.com/masa-finance/masa-oracle-go-testnet.git
cd masa-oracle-go-testnet
#building
go build -v -o masa-node ./cmd/masa-node &> /dev/null
cd $home
#create service
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/masa.service
[Unit]
Description=Masa Node
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/masa-oracle-go-testnet/
ExecStart=$HOME/masa-oracle-go-testnet/masa-node \
        --port=28081 \
        --udp=true \
        --tcp=false \
        --start=true
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl enable masa &>/dev/null
sudo systemctl restart masa &>/dev/null


}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    sudo systemctl disable masa.service
    sudo systemctl disable masa.service
    sudo rm /etc/systemd/system/masa.service 
    sudo rm -rf $HOME/masa-oracle-go-testnet
    echo "Done"
    cd $HOME
    ;;
    *)
        echo Сanceled
        return 0
        ;;
esac
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function