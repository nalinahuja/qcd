#!/usr/bin/env bash

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp

CLEAN="-c"
FORGET="-f"

b=$(tput bold)
n=$(tput sgr0)

# End Global Variables----------------------------------------------------------------------------------------------------------------------------------------------

function format_dir() {
  # Format Directory With Symbols
  command echo -e "${1/$HOME/~}"
}

function add_directory() {
  # Store Directory Information
  local dir=$(pwd)
  local ept=$(basename "$dir")

  # Append To QCD Store If Unique
  if [[ ! "$dir" = "$HOME" && -z $(egrep -s -x ".*:$dir/" $QCD_STORE) ]]
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
  command egrep -s -v -x "${@////}.*" $QCD_STORE > $QCD_TEMP

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
    local paths=$(cat $QCD_STORE | cut -d ':' -f2 | tr ' ' ':' | sort)

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
    local link=$(echo -e "$indicated_dir" | cut -d '/' -f1)
    local subdir=""

    # Get Path Subdirectory If Non-Empty
    if [[ "$indicated_dir" == */* ]]
    then
      subdir=${indicated_dir:${#link} + 1}
    fi

    # Check For File Link(s) In Store File
    local resv=$(egrep -s -x "$link.*" $QCD_STORE)
    local resc=$(echo -e "$resv" | wc -l)

    # Check Result Count
    if [[ $resc -gt 1 ]]
    then
      # Prompt User
      command echo -e "qcd: Multiple paths linked to ${b}$link${n}"

      # Store Paths In Order Of Absolute Path
      local paths=$(echo -e "$resv" | cut -d ':' -f2 | sort)

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
      resv=$(echo -e $paths | cut -d ' ' -f$ept)
    else
      # Set Endpoint
      resv=$(echo -e $resv | cut -d ':' -f2)
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

function _qcd_comp() {
  # Store Current Commandline Argument
  local CURR_ARG=${COMP_WORDS[1]}
  local SUBS_LEN=$(echo -e "$CURR_ARG" | awk -F "/" '{print length($0)-length($NF)}')
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
      RES_DIR="$(cat $QCD_STORE | awk -F ':' '{print $2}' | sort | egrep -s -m1 -x ".*/$LINK_ARG")"
    else
      RES_DIR="$CURR_ARG"
    fi

    # Error Check Resolved Directory
    if [[ ! -z $RES_DIR ]]
    then
      # Get Subdirectories
      SUB_DIRS=$(command ls -CF $RES_DIR | egrep -s -x ".*/" | tr ' ' ':')

      # Generate Word List
      for SUB_DIR in $SUB_DIRS
      do
        # Expand Symbols
        SUB_DIR=${SUB_DIR//:/ }

        # Append To Word List
        WORD_LIST+=("$LINK_ARG$SUB_DIR")
      done

      # Set Completion List
      COMPREPLY=($(compgen -W "$(printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG"))
    fi
  else
    # Endpoint Completion
    local QUICK_DIRS=$(cat $QCD_STORE | awk -F ':' '{printf $1 "/\n"}' | tr ' ' ':' | sort)

    # Add Linked Directories
    for DIR in $QUICK_DIRS
    do
      # Expand Symbols
      DIR=${DIR//:/ }

      # Filter Duplicate Dirs
      if [[ ! -e $DIR ]]
      then
        WORD_LIST+=("$DIR")
      fi
    done

    # Set Completion List
    COMPREPLY=($(compgen -W "$(printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG"))
  fi
}

# End QCD Completion Function---------------------------------------------------------------------------------------------------------------------------------------

# Call QCD Function
qcd $@

# Update Completion List
if [[ -e $QCD_STORE ]]
then
  command complete -o nospace -o dirnames -A directory -F _qcd_comp -X ".*" qcd
fi

# End Main----------------------------------------------------------------------------------------------------------------------------------------------------------
