#!/usr/bin/env bash

#Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Returns
OK=0
ERR=1

# Booleans
TRUE=1
FALSE=0

# Text Formatting
b=$(command tput bold)
n=$(command tput sgr0)

# Actions
QUIT="q"
YES="y"
NO="n"

# Option Flags
CLEAN="-c"
FORGET="-f"
REMEMBER="-r"

# Standalone Flags
HELP="-h"
UPDATE="-u"
VERSION="-v"

# Program Files
QCD_FOLD=~/.qcd
QCD_HELP=~/.qcd/help
QCD_TEMP=~/.qcd/temp
QCD_STORE=~/.qcd/store

# Update Files
QCD_PROG=~/.qcd/qcd.sh
QCD_UPDATE=~/.qcd/update.zip
QCD_INSTALL=~/.qcd/install_qcd

# Release Link
QCD_RELEASES="https://github.com/nalinahuja22/qcd/releases/latest"

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

  # Check For Standalone Flags
  if [[ "$1" = "$HELP" ]]
  then
    # Print Help
    command cat $QCD_HELP

    # Terminate Program
    return $OK
  elif [[ "$1" = "$VERSION" ]]
  then
    # Print Version
    command cat $QCD_HELP | command head -n1

    # Terminate Program
    return $OK
  elif [[ "$1" = "$UPDATE" ]]
  then
    # Read User Input
    command read -p "qcd: Confirm update [y/n]: " confirm

    # Determine Action
    if [[ "${confirm//Y/y}" == $YES ]]
    then
      # Display Prompt
      command echo -en "→ Downloading updates...\r"

      # Get Release Link
      rlink=$(command curl -s -L $QCD_RELEASES | command egrep -s -o "\".*zip\"")

      # Download Release Program Files
      command curl -s -L "https://github.com${rlink//\"/}" > $QCD_UPDATE

      # Display Prompt
      command echo -en "→ Installing updates... \r"

      # Extract And Install Release Program Files
      command unzip -o -j $QCD_UPDATE -d $QCD_FOLD &> /dev/null

      # Cleanup Installation
      command rm $QCD_UPDATE
      command rm $QCD_INSTALL

      # Update Bash Environment
      command source $QCD_PROG

      # Display Prompt
      command echo -e "→ Installation complete   "
    else
      # Display Prompt
      command echo -e "→ Update aborted"
    fi

    # Terminate Program
    return $OK
  fi

  # Check For Option Flags
  if [[ "$1" = "$REMEMBER" ]]
  then
    # Add Current Directory
    add_directory

    # Terminate Program
    return $OK
  elif [[ "${@:$#}" = "$FORGET" ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Remove Current Dir
      remove_directory "$(command pwd)/"
    elif [[ $# -eq 2 ]]
    then
      # Remove Symbolic Link
      remove_symbolic_link "$1"
    fi

    # Terminate Program
    return $OK
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
    return $OK
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

    # Terminate Program
    return $OK
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

        # Error Check Path Results
        if [[ -z $paths ]]
        then
          # Terminate Program
          return $OK
        fi

        # Display Prompt
        command echo -en "qcd: Generating option list...\r"

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
          command printf "(%s) %s\n" "$cnt" "${path%/}" >> $QCD_TEMP
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
          return $ERR
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

      # Terminate Program
      return $ERR
    elif [[ ! -e $resv ]]
    then
      # Check Result Count
      if [[ $resc -gt 1 ]]
      then
        # Print Separator
        command echo
      fi

      # Prompt User Of Error
      command echo -e "qcd: $(format_dir "${resv%/}"): Directory does not exist"

      # Remove Invalid Path From QCD Store
      remove_directory "$resv"

      # Terminate Program
      return $ERR
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

      # Terminate Program
      return $OK
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
        SUB_DIRS="${SUB_DIRS}$(command ls -F "$RES_DIR" 2> /dev/null | command egrep -s -x ".*/" | command tr ' ' ':') "
      done

      # Compress Symbols
      SUB_DIRS=${SUB_DIRS////}

      # Generate Word List
      for SUB_DIR in $SUB_DIRS
      do
        # Expand Symbols
        SUB_DIR=${SUB_DIR//:/ }

        # Append Completion Slash
        if [[ ! -e $LINK_ARG ]]
        then
          WORD_LIST+=("$LINK_ARG/$SUBS_ARG$SUB_DIR/")
        else
          WORD_LIST+=("$LINK_ARG/$SUBS_ARG$SUB_DIR")
        fi
      done

      # Set IFS For COMREPLY
      local IFS=$'\n'

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG" 2> /dev/null))
    fi
  else
    # Linked Directory Completion
    local QUICK_DIRS=$(command cat $QCD_STORE | command awk -F ':' '{printf $1 "/\n"}' | command tr ' ' ':')

    # Store Current Directory Fields
    local CURR_DIR="$(command basename $(command pwd))/"
    local CURR_REM=$FALSE

    # Add Linked Directories
    for QUICK_DIR in $QUICK_DIRS
    do
      # Expand Symbols
      QUICK_DIR=${QUICK_DIR//:/ }

      # Filter Duplicate Dirs
      if [[ ! -e $QUICK_DIR ]]
      then
        # Exlude Current Directory
        if [[ $CURR_REM -eq $FALSE && "$QUICK_DIR" = "$CURR_DIR" ]]
        then
          CURR_REM=$TRUE
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
