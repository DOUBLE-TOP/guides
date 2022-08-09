#!/bin/bash
cd $HOME
source $HOME/.profile
ARCHWAY_ADDR=$(archwayd keys show $ARCHWAY_NODENAME -a)
echo 'export ARCHWAY_ADDR='${ARCHWAY_ADDR} >> $HOME/.profile
ARCHWAY_VALOPER=$(archwayd keys show $ARCHWAY_NODENAME --bech val -a)
echo 'export ARCHWAY_VALOPER='${ARCHWAY_VALOPER} >> $HOME/.profile
source $HOME/.profile
