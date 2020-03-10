#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_STORE=~/.qcd/store

if [[ -e $QCD_STORE ]]
then
  WORD_LIST=$(cat $QCD_STORE | awk '{print $1}')
  complete -o dirnames -W "$WORD_LIST" qcd
fi
