function systemd_holograph {
    sudo tee /etc/systemd/system/holographd.service > /dev/null <<EOF
[Unit]
Description=Holograph
After=network.target

[Service]
Type=simple
User=root
ExecStart=holograph operator --mode=auto --unsafePassword=$password --sync
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable holographd &>/dev/null
sudo systemctl restart holographd
}

password=$(dialog --inputbox "Enter your password from wallet:" 0 0 "your_wallet_pass" --stdout)
echo "creating systemd file, adding to autostart, starting"
systemd_holograph
echo "installation complete, check logs by command:"
echo "sudo journalctl -u holographd -f -o cat"
