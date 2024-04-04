#!/bin/bash

pcli view sync &>/dev/null

current_balance=$(pcli view balance 2>&1 | grep -Eo '[0-9]+\.?[0-9]*penumbra' | awk -Fpenumbra '{print $1}' | awk -F. '{print $1}' | head -1)
dif=1
sleep 1
ceremony_bid=$(($current_balance-$dif))

# Если ceremony_bid больше нуля, используем её значение. Если равно нулю, используем 1penumbra
if [ $ceremony_bid -gt 0 ]; then
    pcli ceremony contribute --phase 2 --bid ${ceremony_bid}penumbra
elif [ $ceremony_bid -eq 0 ]; then
    pcli ceremony contribute --phase 2 --bid 1penumbra
else 
    echo "ERROR: Недостаточный баланс, получите токены с крана в дискорде и повторите попытку"
    exit 1
fi