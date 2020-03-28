#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp

b=$(tput bold)
n=$(tput sgr0)

# End Global Variables----------------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Store First Argument
  indicated_dir="$1"

  # Set To Home Directory If Empty
  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Create QCD Store
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # Indicated Directory Is Valid
  if [[ -e $indicated_dir ]]
  then
    # Change Directory To Indicated Directory
    command cd $indicated_dir

    # Store Complete Path And Endpoint
    local new_dir="$(pwd -P)"
    local new_ept=$(basename $new_dir)

    # Append To QCD Store If Unique
    if [[ ! "$HOME" = "$new_dir" && -z $(egrep -s -x ".* $new_dir" $QCD_STORE) ]]
    then
      command printf "%s %s/\n" $new_ept $new_dir >> $QCD_STORE
    fi

  # Invalid Directory
  else
    # Get Path Prefix and Suffix
    local prefix=$(echo -e "$indicated_dir" | cut -d '/' -f1)
    local suffix=""

    # Get Path Suffix If Non-Empty
    if [[ "$indicated_dir" == *\/* ]]
    then
      suffix=${indicated_dir:${#prefix} + 1}
    fi

    # Check For File Link In Store File
    local res=$(egrep -s -x "$prefix.*" $QCD_STORE)
    local res_cnt=$(echo "$res" | wc -l)

    # Check Result Count
    if [[ $res_cnt -gt 1 ]]
    then
      # Prompt User
      command echo -e "qcd: Multiple paths linked to ${b}$prefix${n}"

      # Store Paths In Order Of Absolute Path
      local paths=$(echo -e "$res" | cut -d ' ' -f2 | sort)

      # Display Options
      local cnt=1
      for path in $paths
      do
        path="~$(echo $path | cut -c $((${#HOME} + 1))-${#path})"
        command printf "(%d) %s\n" $cnt $path
        cnt=$((cnt + 1))
      done

      # Format Selected Endpoint
      command read -p "Endpoint: " ep

      # Error Check Bounds
      if [[ $ep -lt 1 ]]
      then
        ep=1
      elif [[ $ep -gt $res_cnt ]]
      then
        ep=$res_cnt
      fi

      # Format Endpoint
      res=$(echo $paths | cut -d ' ' -f$ep)
    else
      # Format Endpoint
      res=$(echo $res | cut -d ' ' -f2)
    fi

    # Error Check Result
    if [[ -z $res ]]
    then
      # Prompt User
      command echo -e "qcd: Cannot link keyword to directory"
    else
      # Check If Linked Path Is Valid
      if [[ ! -e $res ]]
      then
        # Prompt User
        if [[ $res_cnt -gt 1 ]]; then echo; fi
        local out="~$(echo $res | cut -c $((${#HOME} + 1))-${#res})"
        echo -e "qcd: $out: No such file or directory"

        # Delete Invalid Path From QCD Store
        local del_line=$(egrep -s -n "$res" $QCD_STORE | cut -d ':' -f1)
        command sed "${del_line}d" $QCD_STORE > $QCD_TEMP
        command cat $QCD_TEMP > $QCD_STORE && rm $QCD_TEMP
      else
        # Change Directory To Linked Path
        command cd $res

        # Check If Suffix Exists And Valid
        if [[ ! -z $suffix && -e $suffix ]]
        then
          # Change Directory To Suffix
          command cd $suffix

          # Store Complete Path And Endpoint
          local new_dir="$(pwd -P)"
          local new_ept=$(basename $new_dir)

          # Append To QCD Store If Unique
          if [[ ! "$HOME" = "$new_dir" && -z $(egrep -s -x ".* $new_dir" $QCD_STORE) ]]
          then
            command printf "%s %s/\n" $new_ept $new_dir >> $QCD_STORE
          fi
        fi
      fi
    fi
  fi
}

# Start QCD Function
qcd $1

# End QCD Function--------------------------------------------------------------------------------------------------------------------------------------------------
