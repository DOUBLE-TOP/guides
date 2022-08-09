#!/bin/bash
#Thank's for https://raw.githubusercontent.com/bobu4/massa/main/bal.sh

rm -f $HOME/massa/massa-client/massa-client
if [ ! -e $HOME/massa/massa-client/massa-client ]; then
  wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/massa-client -O $HOME/massa/massa-client/massa-client
  chmod +x $HOME/massa/massa-client/massa-client
fi
#
cd $HOME/massa/massa-client
massa_wallet_address=$(./massa-client wallet_info | grep Address | awk '{ print $2 }')
while true
do
        balance=$(./massa-client wallet_info | grep "Active rolls" | awk '{ print $3 }')
        int_balance=${balance%%.*}
        if [ $int_balance -lt "1" ]; then
                echo "Less than 1"
                resp=$(./massa-client buy_rolls $massa_wallet_address 1 0)
                echo $resp
        elif [ $int_balance -gt "1" ]; then
                echo "More than 1"
        fi
        printf "sleep"
        for((sec=0; sec<60; sec++))
        do
                printf "."
                sleep 1
        done
        printf "\n"
done
