#/usr/bin/env bash

QCD_STORE=~/.qcd/store
WORD_LIST=$(cat $QCD_STORE | awk '{print $1}')

complete -W "$WORD_LIST" qcd
