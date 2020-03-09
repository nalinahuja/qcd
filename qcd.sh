#!/usr/bin/env bash

function qcd() {
  # Error Check
  if [[ -z $1 ]]
  then
    echo -e "qcd: No directory specified."
  else
    # Store First Arg
    indicated_dir=$1

    # Create Dir Store
    if [[ ! -f ~/dev/qcd/.qcd_store ]]
    then
      touch ~/dev/qcd/.qcd_store
    fi

    # Is Valid Directory
    if [[ -e $indicated_dir ]]
    then
      echo "Valid"
      command cd $indicated_dir
      pwd -P >> ~/dev/qcd/.qcd_store
    else
      match=$(egrep -s -m1 "$indicated_dir" ~/dev/qcd/.qcd_store)

      if [[ -z $match ]]
      then
        echo -e "qcd: Cannot match keyword to directory."
      else
        echo "Linked"
        command cd $match
      fi
    fi
  fi
}

qcd $1
