#!/usr/bin/env bash

STORE_FILE=~/.qcd_store
TEMP_FILE=~/.qcd_temp

function qcd() {
  # Store First Arg
  indicated_dir=$1

  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Create Dir Store
  if [[ ! -f $STORE_FILE ]]
  then
    touch $STORE_FILE
  fi

  # Is Valid Directory
  if [[ -e $indicated_dir ]]
  then
    echo "Valid Path"

    # Change Directory
    command cd $indicated_dir

    # Store Complete Path And Endpoint
    new_dir=$(pwd -P)
    new_ept=$(basename $new_dir)

    # Append If Unique
    if [[ -z $(egrep -s -x ".* $new_dir" $STORE_FILE) ]]
    then
      printf "%s %s\n" $new_ept $new_dir >> $STORE_FILE
    fi
  else
    echo "Linked Path"

    res=$(egrep -s -x "$indicated_dir.*" $STORE_FILE)
    res_cnt=$(echo "$res" | wc -l)

    if [[ $res_cnt -gt 1 ]]
    then
      echo -e "qcd: Multiple matches to endpoint"

      paths=$(egrep -s -x "$indicated_dir.*" $STORE_FILE | cut -d ' ' -f2)

      cnt=1
      for path in $paths
      do
        printf "(%d) %s\n" $cnt $path
        cnt=$((cnt + 1))
      done

      read -p "Endpoint: " ep
      res=$(echo $paths | cut -d ' ' -f$ep)
    else
      res=$(echo $res | cut -d ' ' -f2)
    fi

    if [[ -z $res ]]
    then
      echo -e "qcd: Cannot match keyword to directory"
    else
      if [[ ! -e $res ]]
      then
        echo -e "qcd: $res: No such file or directory"
        del_line=$(rep -n "$res" $STORE_FILE | cut -d ':' -f1)
        sed -i "${del_line}d" $STORE_FILE > $TEMP_FILE
        cat $TEMP_FILE > $STORE_FILE && rm $TEMP_FILE
      else
        command cd $res
      fi
    fi
  fi
}

qcd $1
