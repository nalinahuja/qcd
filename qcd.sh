#!/usr/bin/env bash

function qcd() {
  # Store First Arg
  indicated_dir=$1

  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Create Dir Store
  if [[ ! -f ~/dev/qcd/.qcd_store ]]
  then
    touch ~/dev/qcd/.qcd_store
  fi

  # Is Valid Directory
  if [[ -e $indicated_dir ]]
  then
    command cd $indicated_dir

    new_dir=$(pwd -P)
    new_ept=$(basename $new_dir)

    if [[ -z $(egrep -s -m1 -x "$new_ept.*" ~/dev/qcd/.qcd_store) ]]
    then
      printf "%s %s\n" $new_ept $new_dir >> ~/dev/qcd/.qcd_store
    fi
  else
    match=$(egrep -s -m1 -x "$indicated_dir.*" ~/dev/qcd/.qcd_store | cut -d ' ' -f2)

    if [[ -z $match ]]
    then
      echo -e "qcd: Cannot match keyword to directory."
    else
      echo "Linked"
      command cd $match
    fi
  fi
}

qcd $1
