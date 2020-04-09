#!/usr/bin/env bash

# function remove_link() {
#   # Remove Link From Store
#   command egrep -s -v "${1} .*" $QCD_STORE > $QCD_TEMP
#   command mv $QCD_TEMP $QCD_STORE
# }

# # Remove Linked Path(s)
# if [[ "$2" = "$FORGET" ]]
# then
#   local
#
#   remove_directory $(egrep -s -n "$1 .*" $QCD_STORE | cut -d ':' -f1)
#   return
# fi

# qcd space delim handling
# qcd $LINK -f, forget link(s)
# qcd -c, cleanup

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp

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

  # Escape Existing Spaces
  dir="${dir//[ ]/\\ }"
  ept="${ept//[ ]/\\ }"

  # Append To QCD Store If Unique
  if [[ ! "$dir" = "$HOME" && -z $(egrep -s -x ".*:$dir/" $QCD_STORE) ]]
  then
    command printf "$ept:$dir/\n" >> $QCD_STORE
  fi
}

function remove_directory() {
  # Remove Directory From Store
  command egrep -s -v ".*:${1}" $QCD_STORE > $QCD_TEMP
  command mv $QCD_TEMP $QCD_STORE
}

# End Helper Function-----------------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Store Arguments
  indicated_dir="$@"

  # Create QCD Store
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

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
    local resc=$(echo "$resv" | wc -l)

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
      resv=$(echo $paths | cut -d ' ' -f$ept)
    else
      # Set Endpoint
      resv=$(echo $resv | cut -d ':' -f2)
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
      remove_directory $resv
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
  local SUBS_LEN=$(echo "$CURR_ARG" | awk -F "/" '{print length($0)-length($NF)}')
  local LINK_ARG=${CURR_ARG:0:$SUBS_LEN}

  # Initialize Word List
  local WORD_LIST=""

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
      SUB_DIRS=$(command ls -l $RES_DIR | egrep -s ^d | awk '{print $9}')

      # Generate Word List
      for SUB_DIR in $SUB_DIRS
      do
        # Create Temp Sub-Dir
        WORD="$LINK_ARG$SUB_DIR"

        # Append Completion Slash
        if [[ ! -e $WORD ]]
        then
          WORD_LIST="${WORD_LIST} $WORD/"
        else
          WORD_LIST="${WORD_LIST} $WORD"
        fi
      done

      # Set Completion List
      COMPREPLY=($(compgen -W "$WORD_LIST" "$CURR_ARG"))
    fi
  else
    # Endpoint Completion
    local QUICK_DIRS=$(cat $QCD_STORE | awk -F ':' '{printf $1 "/\n"}' | sort)

    # Remove Duplicate Dirs
    for DIR in $QUICK_DIRS
    do
      if [[ ! -e $DIR ]]
      then
        WORD_LIST="${WORD_LIST} $DIR"
      fi
    done

    # Set Completion List
    COMPREPLY=($(compgen -W "$WORD_LIST" "$CURR_ARG"))
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
