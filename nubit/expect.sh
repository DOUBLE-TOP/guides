#!/usr/bin/expect -f
spawn /home/nubit-user/nubit-node/bin/nkey add my_keplr_key --recover --keyring-backend test --node.type light --p2p.network nubit-alphatestnet-1
expect "Enter your bip39 mnemonic"
send "MNEMONIC\r"
interact