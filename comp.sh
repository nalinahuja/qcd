#/usr/bin/env bash

QCD_STORE=~/.qcd/store

word_list=$(cat ~/.qcd/store | awk '{print $1}')

complete -W "$word_list" qcd
