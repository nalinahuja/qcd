#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

#duplicate link, subdir completion

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp

CLEAN="-c"
FORGET="-f"

b=$(command tput bold)
n=$(command tput sgr0)

# End Global Variables----------------------------------------------------------------------------------------------------------------------------------------------

function format_dir() {
  # Format Directory With Symbols
  command echo -e "${1/$HOME/~}"
}

function add_directory() {
  # Store Directory Information
  local dir=$(command pwd)
  local ept=$(command basename "$dir")

  # Append To QCD Store If Unique
  if [[ ! "$dir" = "$HOME" && -z $(command egrep -s -x ".*:$dir/" $QCD_STORE) ]]
  then
    command printf "$ept:$dir/\n" >> $QCD_STORE
  fi
}

function remove_directory() {
  # Remove Directory From Store
  command egrep -s -v -x ".*:${@}" $QCD_STORE > $QCD_TEMP

  # Update File If Successful
  if [[ $? = 0 ]]
  then
    command mv $QCD_TEMP $QCD_STORE
  fi
}

function remove_symbolic_link() {
  # Remove Link From Store
  command egrep -s -v -x "${@////}:.*" $QCD_STORE > $QCD_TEMP

  # Update File If Successful
  if [[ $? = 0 ]]
  then
    command mv $QCD_TEMP $QCD_STORE
  fi
}

# End Helper Function-----------------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Create QCD Store
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # Check For Flags
  if [[ "$1" = "$CLEAN" ]]
  then
    # Get Stored Paths
    local paths=$(command cat $QCD_STORE | command cut -d ':' -f2 | command tr ' ' ':' | command sort)

    # Iterate Over Paths
    for path in $paths
    do
      # Expand Symbols
      path=${path//:/ }

      # Remove Path If Invalid
      if [[ ! -e $path ]]
      then
        remove_directory "$path"
      fi
    done
    return
  elif [[ "${@:$#}" = "$FORGET" ]]
  then
    # Remove Symbolic Link
    local link="${@:0:$(($# - 1))}"
    remove_symbolic_link "$link"
    return
  fi

  # Store Arguments
  indicated_dir="$@"

  # Set To Home Directory If No Path
  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Determine If Path Is Linked
  if [[ -e $indicated_dir ]]
  then
    # Change To Valid Path
    command cd "$indicated_dir"

    # Store Complete Path And Endpoint
    add_directory
  else
    # Get Path Link and Subdirectory
    local link=$(command echo -e "$indicated_dir" | command cut -d '/' -f1)
    local subdir=""

    # Get Path Subdirectory If Non-Empty
    if [[ "$indicated_dir" == */* ]]
    then
      subdir=${indicated_dir:${#link} + 1}
    fi

    # Check For File Link(s) In Store File
    local resv=$(command egrep -s -x "$link.*" $QCD_STORE)
    local resc=$(command echo -e "$resv" | command wc -l)

    # Check Result Count
    if [[ $resc -gt 1 ]]
    then
      # Store Paths In Order Of Absolute Path
      local paths=$(command echo -e "$resv" | command cut -d ':' -f2 | command sort)

      # Store Path Match
      local pmatch=""

      # Determine Linked Subdirectory
      if [[ ! -z $subdir ]]
      then
        for path in $paths
        do
          path="${path}${subdir}"
          if [[ -e $path ]]
          then
            pmatch=$path
            break
          fi
        done
      fi

      # List Matching Links
      if [[ -z $pmatch ]]
      then
        # Prompt User
        command echo -e "qcd: Multiple paths linked to ${b}$link${n}"

        # Display Options
        local cnt=1
        for path in $paths
        do
          path=$(format_dir $path)
          command printf "(%d) %s\n" $cnt $path
          cnt=$((cnt + 1))
        done

        # Format Selected Endpoint
        command read -p "Endpoint: " ept

        # Error Check Bounds
        if [[ $ept -lt 1 ]]
        then
          ept=1
        elif [[ $ept -gt $resc ]]
        then
          ept=$resc
        fi

        # Set Endpoint
        resv=$(command echo -e $paths | command cut -d ' ' -f$ept)
      else
        # Set Endpoint
        resv=$pmatch
      fi
    else
      # Set Endpoint
      resv=$(command echo -e $resv | command cut -d ':' -f2)
    fi

    # Error Check Result
    if [[ -z $resv ]]
    then
      # Prompt User Of No Link
      command echo -e "qcd: Cannot link keyword to directory"
    elif [[ ! -e $resv ]]
    then
      # Prompt User Of Error
      if [[ $resc -gt 1 ]]; then echo; fi
      command echo -e "qcd: $(format_dir $resv): Directory does not exist"

      # Remove Invalid Path From QCD Store
      remove_directory "$resv"
    else
      # Change Directory To Linked Path
      command cd "$resv"

      # Check If Subdirectory Exists
      if [[ ! -z $subdir && -e $subdir ]]
      then
        # Change Directory To Subdirectory
        command cd "$subdir"

        # Store Complete Path And Endpoint
        add_directory
      fi
    fi
  fi
}

# End QCD Function---------------------------------------------------------------------------------------------------------------------------------------------------
