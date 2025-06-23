#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add riscv32i-unknown-none-elf

sudo apt install -y protobuf-compiler

curl https://cli.nexus.xyz/ | sh

source /root/.bashrc

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/refs/heads/main/glibc239.sh | bash &>/dev/null


echo "Установка Nexus завершена. Продолжайте по гайду"
root@vesta-yyu4hj:~# nano nexus.sh
root@vesta-yyu4hj:~# cat nexus.sh
#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add riscv32i-unknown-none-elf

sudo apt install -y protobuf-compiler

curl https://cli.nexus.xyz/ | sh

source /root/.bashrc

echo "Установка Nexus завершена. Продолжайте по гайду"
