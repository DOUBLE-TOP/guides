#!/bin/bash
#Thank's for https://raw.githubusercontent.com/bobu4/massa/main/bal.sh

# rm -f $HOME/massa/massa-client/massa-client
# if [ ! -e $HOME/massa/massa-client/massa-client ]; then
#   wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/massa-client -O $HOME/massa/massa-client/massa-client
#   chmod +x $HOME/massa/massa-client/massa-client
# fi
# #
source $HOME/.profile
cd $HOME/massa/massa-client
massa_wallet_address=$(./massa-client --pwd $massa_pass wallet_info | grep Address | awk '{ print $2 }')
while true
do
        balance=$(./massa-client --pwd $massa_pass wallet_info | grep "Rolls" | awk '{ print $3 }' | sed 's/final=//;s/,//')
        int_balance=${balance%%.*}
        if [ $int_balance -lt "1" ]; then
                echo "Less than 1 Final Roll"
                resp=$(./massa-client --pwd $massa_pass buy_rolls $massa_wallet_address 1 0)
                echo $resp
        elif [ $int_balance -gt "1" ]; then
                echo "More than 1 Final Roll"
        fi
        date=$(date +"%H:%M")
        echo Last Update: ${date}
        printf "sleep"
        for((m=0; m<60; m++))
        do
                printf "."
                sleep 1m
        done
        printf "\n"
done
