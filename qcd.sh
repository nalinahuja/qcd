#!/usr/bin/env bash

#Developed by Nalin Ahuja, nalinahuja22

TRUE=1
FALSE=0

QUIT="q"
HELP="-h"
CLEAN="-c"
FORGET="-f"
REMEMBER="-r"

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp
QCD_HELP=~/.qcd/help

b=$(command tput bold)
n=$(command tput sgr0)

# End Defined Constants----------------------------------------------------------------------------------------------------------------------------------------------

function format_dir() {
  # Format Home Directory
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

  # Store Directory If Unique
  if [[ ! "${dir%/}" = "${HOME%/}" && -z $(command egrep -s -x ".*:$dir/" $QCD_STORE) ]]
  then
    # Append Directory Data To Store File
    command printf "$ept:$dir/\n" >> $QCD_STORE

    # Sort Store File
    command sort -o $QCD_STORE -n -t ':' -k2 $QCD_STORE
  fi
}

function remove_directory() {
  # Remove Directory From Store
  command egrep -s -v -x ".*:${@}" $QCD_STORE > $QCD_TEMP

  # Update Store If Successful
  update_store $?
}

function remove_symbolic_link() {
  # Remove Link From Store
  command egrep -s -v -x "${@////}:.*" $QCD_STORE > $QCD_TEMP

  # Update Store If Successful
  update_store $?
}

# End Helper Function-----------------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Create Store File
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # Check For Commandline Flags
  if [[ "$1" = "$HELP" ]]
  then
    # Print Help
    command cat $QCD_HELP

    # Terminate Program
    return
  elif [[ "$1" = "$REMEMBER" ]]
  then
    # Add Current Directory
    add_directory

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
  elif [[ "$1" = "$CLEAN" ]]
  then
    # Get Compressed Paths From Store File
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
  fi

  # Store Commandline Arguments
  indicated_dir="$@"

  # Set To Home Directory If No Arguments
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
    # Get Path Link and Relative Subdirectory
    local link=$(command echo -e "$indicated_dir" | command cut -d '/' -f1)
    local sdir=""

    # Get Path Subdirectory If Non-Empty
    if [[ "$indicated_dir" == */* ]]
    then
      sdir=${indicated_dir:${#link} + 1}
    fi

    # Store Symbolic Linkages From Store File
    local resv=$(command egrep -s -x "$link.*:.*" $QCD_STORE 2> /dev/null)
    local resc=$(command echo -e "$resv" | command wc -l)

    # Check Result Count
    if [[ $resc -gt 1 ]]
    then
      # Store Matching Absolute Paths
      local paths=$(command echo -e "$resv" | command cut -d ':' -f2 | command tr ' ' ':')

      # Store Current Directory
      local dir=$(command pwd)

      # Initialize Path Match
      local pmatch=""

      # Initialize Filtered Paths
      local fpaths=""

      # Initialize Ignore Boolean
      local ignore_paths=$FALSE

      # Reset Result Count
      resc=0

      # Iterate Over Paths
      for path in $paths
      do
        # Expand Symbols
        path=${path//:/ }

        # Form Complete Path
        path="${path}${sdir}"

        # Check Path Existence
        if [[ -e $path && ! "${path%/}" = "${dir%/}" ]]
        then
          # Select Matched Path
          if [[ -z $pmatch && $ignore_paths -eq $FALSE ]]
          then
            # Select Path
            pmatch=$path
          else
            # Set Ignore Boolean
            ignore_paths=$TRUE

            # Unselect Path
            pmatch=""
          fi

          # Compress Symbols
          path=${path// /:}

          # Add Path To Filtered List
          fpaths="${fpaths}$path "
          resc=$((resc + 1))
        fi
      done

      # List Matching Links
      if [[ -z $pmatch ]]
      then
        # Replace Path Results
        paths=$fpaths

        # Generate Prompt
        command echo -e "qcd: Multiple paths linked to ${b}${indicated_dir%/}${n}" > $QCD_TEMP

        # Generate Path Options
        local cnt=1
        for path in $paths
        do
          # Format Path
          path=$(format_dir $path)

          # Expand Symbols
          path=${path//:/ }

          # Output Path As Option
          command printf "(%d) %s\n" $cnt "${path%/}" >> $QCD_TEMP
          cnt=$((cnt + 1))
        done

        # Display Prompt
        command cat $QCD_TEMP

        # Read User Input
        command read -p "Endpoint: " ept

        # Error Check Input
        if [[ -z $ept || $ept = $QUIT || ! $ept =~ ^[0-9]+$ ]]
        then
          # Terminate Program
          return
        elif [[ $ept -lt 1 ]]
        then
          # Set To Minimum Selection
          ept=1
        elif [[ $ept -gt $resc ]]
        then
          # Set To Maximum Selection
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

    # Expand Symbols
    resv=${resv//:/ }

    # Error Check Result
    if [[ -z $resv ]]
    then
      # Prompt User Of No Link
      command echo -e "qcd: Cannot link keyword to directory"
    elif [[ ! -e $resv ]]
    then
      # Check Result Count
      if [[ $resc -gt 1 ]]
      then
        # Print Separator
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
  # Initialize Word List
  local WORD_LIST=()

  # Store Current Commandline Argument
  local CURR_ARG=${COMP_WORDS[1]}

  # Path Completion
  if [[ "$CURR_ARG" == */* ]]
  then
    # Obtain Symbolic Link
    local LINK_ARG=$(command echo -e "$CURR_ARG" | command cut -d "/" -f1)
    local LINK_LEN=${#LINK_ARG}

    # Obtain Truncated Path
    local SUBS_LEN=$(command echo -e "$CURR_ARG" | command awk -F "/" '{print length($0)-length($NF)}')
    local SUBS_ARG=${CURR_ARG:0:$SUBS_LEN}
    SUBS_ARG=${SUBS_ARG:$LINK_LEN + 1}

    # Store Resolved Directories
    local RES_DIRS=""

    # Resolve Linked Directories
    if [[ ! -e $CURR_ARG ]]
    then
      # Obtain Compressed Linked Paths From Store File
      LINK_PATHS=$(command cat $QCD_STORE | command egrep -s -x "$LINK_ARG:.*" | command awk -F ':' '{print $2}' | command tr ' ' ':')

      # Iterate Over Paths
      for LINK_PATH in $LINK_PATHS
      do
        # Expand Symbols
        LINK_PATH=${LINK_PATH//:/ }

        # Form Resolved Directory
        RES_DIR="$LINK_PATH$SUBS_ARG"

        # Add Resolved Valid Directory
        if [[ -e $RES_DIR ]]
        then
          # Compress Symbols
          RES_DIR=${RES_DIR// /:}
          RES_DIRS="${RES_DIRS}$RES_DIR "
        fi
      done
    else
      # Resolve Local Directories
      RES_DIRS="$CURR_ARG"
    fi

    # Error Check Resolved Directory
    if [[ ! -z $RES_DIRS ]]
    then
      # Initialize Subdirectories
      SUB_DIRS=""

      # Store Subdirectories Of Resolved Directories
      for RES_DIR in $RES_DIRS
      do
        # Expand Symbols
        RES_DIR=${RES_DIR//:/ }

        # Add Subdirectory To List
        SUB_DIRS="${SUB_DIRS}$(command ls -F "$RES_DIR" 2> /dev/null | command egrep -s -x ".*/")"
      done

      # Compress Symbols
      SUB_DIRS=${SUB_DIRS// /:}
      SUB_DIRS=${SUB_DIRS////}

      # Generate Word List
      for SUB_DIR in $SUB_DIRS
      do
        # Expand Symbols
        SUB_DIR=${SUB_DIR//:/ }

        # Add Path To Wordlist
        WORD_LIST+=("$LINK_ARG/$SUBS_ARG$SUB_DIR/")
      done

      # Set IFS For COMREPLY
      local IFS=$'\n'

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
        WORD_LIST+=("$QUICK_DIR")
      fi
    done

    # Set IFS For COMREPLY
    local IFS=$'\n'

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
