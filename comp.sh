#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_STORE=~/.qcd/store

# End Global Variables-----------------------------------------------------------------------------------------------------------------------------------------------

function _qcd_comp() {
  # Store Current Commandline Argument
  local CURR_ARG=${COMP_WORDS[1]}
  local SUBS_LEN=$(command echo -e "$CURR_ARG" | command awk -F "/" '{print length($0)-length($NF)}')
  local LINK_ARG=${CURR_ARG:0:$SUBS_LEN}

  # Initialize Word List
  local WORD_LIST=()
  local IFS=$'\n'

  # Path Completion
  if [[ "$LINK_ARG" == */* ]]
  then
    # Determine Resolved Directory
    if [[ ! -e $CURR_ARG ]]
    then
      RES_DIR="$(command cat $QCD_STORE | command awk -F ':' '{print $2}' | command sort | command egrep -s -m1 -x ".*/$LINK_ARG")"
    else
      RES_DIR="$CURR_ARG"
    fi

    # Error Check Resolved Directory
    if [[ ! -z $RES_DIR ]]
    then
      # Get Subdirectories
      SUB_DIRS=$(command ls -F $RES_DIR | command egrep -s -x ".*/")
      SUB_DIRS=${SUB_DIRS// /:}
      SUB_DIRS=${SUB_DIRS////}

      # Generate Word List
      for SUB_DIR in $SUB_DIRS
      do
        # Expand Symbols
        SUB_DIR=${SUB_DIR//:/ }

        # Append To Word List
        WORD_LIST+=("$LINK_ARG$SUB_DIR/")
      done

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG"))
    fi
  else
    # Endpoint Completion
    local QUICK_DIRS=$(command cat $QCD_STORE | command awk -F ':' '{printf $1 "/\n"}' | command tr ' ' ':' | command sort)

    # Add Linked Directories
    for DIR in $QUICK_DIRS
    do
      # Expand Symbols
      DIR=${DIR//:/ }

      # Filter Duplicate Dirs
      if [[ ! -e $DIR ]]
      then
        WORD_LIST+=($DIR)
      fi
    done

    # Set Completion List
    COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG"))
  fi
}

# End QCD Comp Function----------------------------------------------------------------------------------------------------------------------------------------------

# Update Completion List
if [[ -e $QCD_STORE ]]
then
  command complete -o nospace -o dirnames -A directory -F _qcd_comp -X ".*" qcd
fi

# End QCD Completion Function----------------------------------------------------------------------------------------------------------------------------------------
