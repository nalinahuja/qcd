#!/usr/bin/env bash

QCD_STORE=~/.qcd_store
QCD_TEMP=~/.qcd_temp

function qcd() {
  # Store First Arg
  indicated_dir=$1

  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Create Dir Store
  if [[ ! -f $QCD_STORE ]]
  then
    touch $QCD_STORE
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
    if [[ -z $(egrep -s -x ".* $new_dir" $QCD_STORE) ]]
    then
      printf "%s %s\n" $new_ept $new_dir >> $QCD_STORE
    fi
  else
    echo "Linked Path"

    res=$(egrep -s -x "$indicated_dir.*" $QCD_STORE)
    res_cnt=$(echo "$res" | wc -l)

    if [[ $res_cnt -gt 1 ]]
    then
      echo -e "qcd: Multiple matches to endpoint"

      paths=$(egrep -s -x "$indicated_dir.*" $QCD_STORE | cut -d ' ' -f2)

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
        if [[ $res_cnt -gt 1 ]]
        then
          echo -e ""
        fi

        echo -e "qcd: $res: No such file or directory"
        del_line=$(grep -n "$res" $QCD_STORE | cut -d ':' -f1)
        sed "${del_line}d" $QCD_STORE > $QCD_TEMP
        cat $QCD_TEMP > $QCD_STORE && rm $QCD_TEMP
      else
        command cd $res
      fi
    fi
  fi
}

qcd $1
