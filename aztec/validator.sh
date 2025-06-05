#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

source ~/.bashrc
source ~/.profile
cd aztec || exit

if [ ! -f .env ]; then
  echo ".env файл не найден. Скрипт завершен."
  exit 1
fi

export $(grep -v '^#' .env | xargs)

TIMETOGO="$1"

if [ -z "$TIMETOGO" ] || ! [[ "$TIMETOGO" =~ ^[0-9]+$ ]]; then
  echo "Ошибка: укажите время регистрации валидатора как числовой аргумент. Например nohup ./aztec_validator.sh 1749125131 > /var/log/aztec_validator.log 2>&1 &"
  exit 1
fi

# Loop until current time > TIMETOGO
while true; do
  CURRENT_TIME=$(date +%s)

  echo "Ожидание времени $TIMETOGO. Время сейчас: $CURRENT_TIME"

  if [ "$CURRENT_TIME" -gt "$TIMETOGO" ]; then
    echo "Время достигнуто: $CURRENT_TIME > $TIMETOGO"
    aztec add-l1-validator \
      --l1-rpc-urls "$ETHEREUM_RPC_URL" \
      --private-key "$VALIDATOR_PRIVATE_KEY" \
      --attester "$COINBASE" \
      --proposer-eoa "$COINBASE" \
      --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
      --l1-chain-id 11155111
    echo "Валидатор успешно зарегистрирован."

    break
  fi

  sleep 10
done
