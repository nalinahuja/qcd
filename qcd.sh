#!/usr/bin/env bash

#Developed by Nalin Ahuja, nalinahuja22

TRUE=1
FALSE=0

QUIT="q"
HELP="-h"
CLEAN="-c"
FORGET="-f"

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp
QCD_HELP=~/.qcd/help

b=$(command tput bold)
n=$(command tput sgr0)

# End Defined Constants----------------------------------------------------------------------------------------------------------------------------------------------

function format_dir() {
  # Format Directory With Symbols
  command echo -e ${1/$HOME/\~}
}

function update_store() {
  # Check Exit Status
  if [[ $1 -eq 0 ]]
  then
    # Update Store File
    command mv $QCD_TEMP $QCD_STORE
  else
    # Remove Temp File
    command rm $QCD_TEMP
  fi
}

function add_directory() {
  # Store Directory Information
  local dir=$(command pwd)
  local ept=$(command basename "$dir")

  # Store If Directory Is Unique
  if [[ ! "$dir" = "$HOME" && -z $(command egrep -s -x ".*:$dir/" $QCD_STORE) ]]
  then
    # Append Directory Data To QCD Store
    command printf "$ept:$dir/\n" >> $QCD_STORE

    # Sort QCD Store
    command sort -o $QCD_STORE -n -t ':' -k2 $QCD_STORE
  fi
}

function remove_directory() {
  # Remove Directory From Store
  command egrep -s -v -x ".*:${@}" $QCD_STORE > $QCD_TEMP

  # Update File If Successful
  update_store $?
}

function remove_symbolic_link() {
  # Remove Link From Store
  command egrep -s -v -x "${@////}:.*" $QCD_STORE > $QCD_TEMP

  # Update File If Successful
  update_store $?
}

# End Helper Function-----------------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Create QCD Store
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # Check For Flags
  if [[ "$1" = "$HELP" ]]
  then
    # Print Help
    cat $QCD_HELP

    # Terminate Program
    return
  elif [[ "$1" = "$CLEAN" ]]
  then
    # Get Stored Paths
    local paths=$(command cat $QCD_STORE | command cut -d ':' -f2 | command tr ' ' ':')

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

    # Terminate Program
    return
  elif [[ "${@:$#}" = "$FORGET" ]]
  then
    # Get Symbolic Link
    local link="${@:1:1}"

    # Determine Removal Type
    if [[ "$link" = "$FORGET" ]]
    then
      local path=$(command pwd)
      remove_directory "$path/"
    else
      remove_symbolic_link "$link"
    fi

    # Terminate Program
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
    local sdir=""

    # Get Path Subdirectory If Non-Empty
    if [[ "$indicated_dir" == */* ]]
    then
      sdir=${indicated_dir:${#link} + 1}
    fi

    # Check For File Link(s) In Store File
    local resv=$(command egrep -s -x "$link.*" $QCD_STORE 2> /dev/null)
    local resc=$(command echo -e "$resv" | command wc -l)

    # Check Result Count
    if [[ $resc -gt 1 ]]
    then
      # Store Paths In Order Of Absolute Path
      local paths=$(command echo -e "$resv" | command cut -d ':' -f2)

      # Store Path Match
      local pmatch=""

      # Determine Linked Subdirectory
      if [[ ! -z $sdir ]]
      then
        for path in $paths
        do
          # Generate Full Paths
          path="${path}${sdir}"

          # Check Path Existence
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

        # Error Check Input
        if [[ -z $ept || $ept = $QUIT || ! $ept =~ ^[0-9]+$ ]]
        then
          # Terminate Program
          return
        fi

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
      # Print Separator
      if [[ $resc -gt 1 ]]
      then
        echo
      fi

      # Prompt User Of Error
      command echo -e "qcd: $(format_dir $resv): Directory does not exist"

      # Remove Invalid Path From QCD Store
      remove_directory "$resv"
    else
      # Change Directory To Linked Path
      command cd "$resv"

      # Check If Subdirectory Exists
      if [[ ! -z $sdir && -e $sdir ]]
      then
        # Change Directory To Subdirectory
        command cd "$sdir"

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
  local SUBS_LEN=$(command echo -e "$CURR_ARG" | command awk -F "/" '{print length($0)-length($NF)}')
  local LINK_ARG=${CURR_ARG:0:$SUBS_LEN}

  # Initialize Word List
  local WORD_LIST=()

  # Path Completion
  if [[ "$LINK_ARG" == */* ]]
  then
    # Determine Resolved Directory
    if [[ ! -e $CURR_ARG ]]
    then
      RES_DIR="$(command cat $QCD_STORE | command awk -F ':' '{print $2}' | command egrep -s -x ".*/$LINK_ARG")"
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

        # Append Completion Slash
       if [[ ! -e $LINK_ARG ]]
       then
         WORD_LIST+=("$LINK_ARG$SUB_DIR/")
       else
         WORD_LIST+=("$LINK_ARG$SUB_DIR")
       fi
      done

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG" 2> /dev/null))
    fi
  else
    # Endpoint Completion
    local QUICK_DIRS=$(command cat $QCD_STORE | command awk -F ':' '{printf $1 "/\n"}' | command tr ' ' ':')

    # Resolve Current Directory Name
    local CURR_DIR="$(command basename $(command pwd))/"
    local REM=$FALSE

    # Add Linked Directories
    for QUICK_DIR in $QUICK_DIRS
    do
      # Expand Symbols
      QUICK_DIR=${QUICK_DIR//:/ }

      # Filter Duplicate Dirs
      if [[ ! -e $QUICK_DIR ]]
      then
        # Exlude Current Directory
        if [[ $REM -eq $FALSE && "$QUICK_DIR" = "$CURR_DIR" ]]
        then
          REM=$TRUE
          continue
        fi

        # Add Dirs To Word List
        WORD_LIST+=($QUICK_DIR)
      fi
    done

    # Set Completion List
    COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG" 2> /dev/null))
  fi
}

# End QCD Completion Function----------------------------------------------------------------------------------------------------------------------------------------

# Initialize Completion Function
if [[ -e $QCD_STORE ]]
then
  command complete -o nospace -o dirnames -A directory -F _qcd_comp -X ".*" qcd
fi

# Cleanup File
qcd -c

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
