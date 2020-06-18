#!/usr/bin/env bash

#Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Return Values
OK=0
ERR=1

# Conditional Booleans
TRUE=1
FALSE=0

# Text Formatting
B=$(command tput bold)
N=$(command tput sgr0)

# Program Actions
YES="y"
QUIT="q"

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
QCD_HELP=$QCD_FOLD/help
QCD_TEMP=$QCD_FOLD/temp
QCD_STORE=$QCD_FOLD/store

# Update Files
QCD_UPDATE=$QCD_FOLD/update.zip

# Release Link
QCD_RELEASES="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End Defined Constants----------------------------------------------------------------------------------------------------------------------------------------------

function format_dir() {
  # Compress Home Directory
  command echo -e ${1/$HOME/\~}
}

function update_store() {
  # Check Exit Status
  if [[ $1 -eq $OK ]]
  then
    # Update Store File
    command mv $QCD_TEMP $QCD_STORE
  else
    # Remove Temp File
    command rm $QCD_TEMP 2> /dev/null
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

# End Helper Functions-----------------------------------------------------------------------------------------------------------------------------------------------

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
    # Prompt User For Confirmation
    command read -p "qcd: Confirm update [y/n]: " confirm

    # Determine Action
    if [[ "${confirm//Y/y}" == $YES ]]
    then
      # Display Prompt
      command echo -en "→ Downloading update "

      # Get Release Link
      release_url=$(command curl -s -L $QCD_RELEASES | command egrep -s -o "https.*zipball.*")

      # Download Release Program Files
      command curl -s -L "${release_url/\",/}" > $QCD_UPDATE

      # Error Check Update
      if [[ $? -gt $OK || ! -f $QCD_UPDATE ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to download update"

        # Terminate Program
        return $ERR
      fi

      # Display Prompt
      command echo -en "\r→ Installing updates "

      # Extract And Install Release Program Files
      command unzip -o -j $QCD_UPDATE -d $QCD_FOLD &> /dev/null

      # Error Check Installation
      if [[ $? -gt $OK ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to install update"

        # Terminate Program
        return $ERR
      fi

      # Cleanup Installation
      command rm $QCD_UPDATE 2> /dev/null
      command rm $QCD_FOLD/install_qcd 2> /dev/null

      # Update Bash Environment
      command source $QCD_FOLD/qcd.sh &> /dev/null

      # Display Prompt
      command echo -e "\r→ Update complete    "
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
      # Remove Current Directory
      remove_directory "$(command pwd)/"
    else
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

      # Remove Invalid Paths
      if [[ ! -e $path ]]
      then
        remove_directory "$path"
      fi
    done

    # Terminate Program
    return $OK
  fi

  # Store Command Line Arguments
  indicated_dir="$@"

  # Set To Home Directory If No Arguments
  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Determine If Directory Is Linked
  if [[ -e $indicated_dir ]]
  then
    # Change To Valid Directory
    command cd "$indicated_dir"

    # Store Complete Path And Endpoint
    add_directory

    # Terminate Program
    return $OK
  else
    # Get Directory Link and Relative Subdirectory
    local link=$(command echo -e "$indicated_dir" | command cut -d '/' -f1)
    local sdir=""

    # Get Subdirectory If Non-Empty
    if [[ "$indicated_dir" == */* ]]
    then
      sdir=${indicated_dir:${#link} + 1}
    fi

    # Get Symbolic Linkages From Store File
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
        # Form Expanded Complete Path
        path="${path//:/ }${sdir}"

        # Check Path Validity
        if [[ -e $path && ! "${path%/}" = "${dir%/}" ]]
        then
          # Determine Path Match
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

          # Add Compressed Path To Filtered List
          fpaths="${fpaths}${path// /:} "
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
        command echo -e "qcd: Multiple paths linked to ${B}${indicated_dir%/}${N}" > $QCD_TEMP

        # Generate Path Options
        local cnt=1
        for path in $paths
        do
          # Format Path
          path=$(format_dir "$path")

          # Expand Symbols
          path=${path//:/ }

          # Output Path As Option
          command printf "($cnt) ${path%/}\n" >> $QCD_TEMP
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

        # Set Manually Selected Endpoint
        resv=$(command echo -e $paths | command cut -d ' ' -f$ept)
      else
        # Set Automatically Selected Endpoint
        resv=$pmatch
      fi
    else
      # Set Default Endpoint
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

      # Remove Current Directory
      remove_directory "$resv"

      # Terminate Program
      return $ERR
    else
      # Switch To Linked Path
      command cd "$resv"

      # Check If Subdirectory Exists
      if [[ ! -z $sdir && -e $sdir ]]
      then
        # Switch To Subdirectory
        command cd "$sdir"

        # Add Current Directory
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
        # Form Expanded Resolved Directory
        RES_DIR="${LINK_PATH//:/ }$SUBS_ARG"

        # Add Resolved Valid Directory
        if [[ -e $RES_DIR ]]
        then
          RES_DIRS="${RES_DIRS}${RES_DIR// /:} "
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
        # Add Subdirectory To List
        SUB_DIRS="${SUB_DIRS}$(command ls -F "${RES_DIR//:/ }" 2> /dev/null | command egrep -s -x ".*/" | command tr ' ' ':') "
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

      # Filter Duplicate Directories
      if [[ ! -e $QUICK_DIR ]]
      then
        # Exlude Current Directory
        if [[ $CURR_REM -eq $FALSE && "$QUICK_DIR" = "$CURR_DIR" ]]
        then
          CURR_REM=$TRUE
          continue
        fi

        # Add Directories To Word List
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

# Initialize QCD
if [[ -f $QCD_STORE ]]
then
  # Initialize Completion Function
  command complete -o nospace -o dirnames -A directory -F _qcd_comp -X ".*" qcd

  # Cleanup Store File
  qcd -c
fi

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
