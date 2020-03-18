#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_STORE=~/.qcd/store

function _qcd_comp() {
  # Store Current Commandline Argument
  CURR_ARG=${COMP_WORDS[1]}
  LINK_ARG=${CURR_ARG:0:$(echo "${COMP_WORDS[1]}" | awk -F "/" '{print length($0)-length($NF)}')}

  # Initialize Word List
  WORD_LIST=""

  # Path Completion
  if [[ "$LINK_ARG" == *\/* ]]
  then
    if [[ ! -e $CURR_ARG ]]
    then
      RES_DIR="$(cat $QCD_STORE | awk '{print $2}' | sort | egrep -s -m1 "$LINK_ARG")"
    else
      RES_DIR="$CURR_ARG"
    fi

    SUB_DIRS=$(command ls -l $RES_DIR | grep ^d | awk '{print $9}')

    # Check RES_DIR
    if [[ ! -z $RES_DIR ]]
    then
      # Generate WORD_LIST
      for SUB_DIR in $SUB_DIRS
      do
        # Create Temp Sub-Dir
        WORD="$LINK_ARG$SUB_DIR"

        # Append Completion Slash
        if [[ ! -e $CURR_ARG ]]
        then
          WORD_LIST="${WORD_LIST} $WORD/"
        else
          WORD_LIST="${WORD_LIST} $WORD"
        fi
      done

      COMPREPLY=($(compgen -W "$WORD_LIST" "${COMP_WORDS[1]}"))
    fi
  else
    # Endpoint Completion
    WORD_LIST=$(cat $QCD_STORE | awk '{print $1}' | sort)
    COMPREPLY=($(compgen -W "$WORD_LIST" "${COMP_WORDS[1]}"))
  fi
}

if [[ -e $QCD_STORE ]]
then
  complete -o nospace -o dirnames -A directory -F _qcd_comp -X ".*" qcd
fi
