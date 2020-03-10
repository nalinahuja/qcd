#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_STORE=~/.qcd/store

function _qcd_comp() {
  # Store Current Commandline Argument
  curr_arg=${COMP_WORDS[1]}

  # Initialize Word List
  WORD_LIST=""

  # Path Completion
  if [[ "$curr_arg" == *\/* ]]
  then
    WORD_LIST=$(cat $QCD_STORE | awk '{print $2}' | sort | egrep -s "$curr_arg")
    NEW_LIST=""

    for WORD in $WORD_LIST
    do
      word_len=${#WORD}
      prefix=${WORD%%$curr_arg*}
      prefix_len=$((${#prefix} + 1))

      NEW_LIST="${NEW_LIST} $(echo $WORD | cut -c $prefix_len-$word_len)"
    done

    COMPREPLY=($(compgen -W "$NEW_LIST" "${COMP_WORDS[1]}"))
  else
    # Endpoint Completion
    WORD_LIST=$(cat $QCD_STORE | awk '{print $1}' | sort)
    COMPREPLY=($(compgen -W "$WORD_LIST" "${COMP_WORDS[1]}"))
  fi
}

if [[ -e $QCD_STORE ]]
then
  complete -o dirnames -A directory -F _qcd_comp -X ".*" qcd
fi
