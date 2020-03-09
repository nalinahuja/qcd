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
    # Change Directory
    command cd $indicated_dir

    # Store Complete Path And Endpoint
    new_dir=$(pwd -P)
    new_ept=$(basename $new_dir)

    # Append If Unique
    if [[ -z $(egrep -s -x ".* $new_dir" ~/dev/qcd/.qcd_store) ]]
    then
      printf "%s %s\n" $new_ept $new_dir >> ~/dev/qcd/.qcd_store
    fi
  else
    res=$(egrep -s -x "$indicated_dir.*" ~/dev/qcd/.qcd_store)
    res_cnt=$(echo "$res" | wc -l)

    if [[ $res_cnt -gt 1 ]]
    then
      echo -e "qcd: Multiple matches to endpoint"

      paths=$(egrep -s -x "$indicated_dir.*" ~/dev/qcd/.qcd_store | cut -d ' ' -f2)

      cnt=1
      for path in $paths
      do
        printf "(%d) %s\n" $cnt $path
        cnt=$((cnt + 1))
      done

      read -p "Endpoint: " ep
      res=$(echo $paths | cut -d ' ' -f$ep)
    fi

    if [[ -z $res ]]
    then
      echo -e "qcd: Cannot match keyword to directory"
    else
      if [[ ! -e $res ]]
      then
        echo -e "qcd: $res: No such file or directory"
      else
        command cd $res
      fi
    fi
  fi
}

qcd $1
