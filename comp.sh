#/usr/bin/env bash

QCD_STORE=~/.qcd/store

if [[ -f $QCD_STORE ]]
then
  WORD_LIST=$(cat $QCD_STORE | awk '{print $1}')
  complete -W "$WORD_LIST" qcd
fi
