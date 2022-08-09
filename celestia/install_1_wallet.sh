#!/bin/bash
cd $HOME
source $HOME/.profile
CELESTIA_ADDR=$(celestia-appd keys show $CELESTIA_NODENAME -a)
echo 'export CELESTIA_ADDR='${CELESTIA_ADDR} >> $HOME/.profile
CELESTIA_VALOPER=$(celestia-appd keys show $CELESTIA_NODENAME --bech val -a)
echo 'export CELESTIA_VALOPER='${CELESTIA_VALOPER} >> $HOME/.profile
source $HOME/.profile
