#!/usr/bin/env bash

#TODO, documentation updates (reserved characters, flags)
#TODO, relative directories in auto complete

#Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Return Values
OK=0
ERR=1
CONT=2
NFD=127

# Conditional Booleans
TRUE=1
FALSE=0

# End Defined Numerical Constants------------------------------------------------------------------------------------------------------------------------------------

# User Actions
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

# Text Formatting
B=$(command tput bold)
N=$(command tput sgr0)

# Higher Directory Pattern
HWD="../"

# End Defined String Constants---------------------------------------------------------------------------------------------------------------------------------------

# Program Files
QCD_FOLD=~/.qcd
QCD_HELP=$QCD_FOLD/help
QCD_TEMP=$QCD_FOLD/temp
QCD_STORE=$QCD_FOLD/store
QCD_UPDATE=$QCD_FOLD/update.zip

# Update Release Link
QCD_RELEASES="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End Defined Program Constants--------------------------------------------------------------------------------------------------------------------------------------

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
  # Get Current Directory
  local dir=$(command pwd)

  # Store Directory If Unique
  if [[ ! "${dir%/}" = "${HOME%/}" && -z $(command egrep -s -x ".*:$dir/" $QCD_STORE) ]]
  then
    # Get Basename Of Current Directory
    local ept=$(command basename "$dir")

    # Append Directory Data To Store File
    command printf "$ept:$dir/\n" >> $QCD_STORE

    # Sort Store File
    command sort -o $QCD_STORE -n -t ':' -k2 $QCD_STORE
  fi
}

function remove_directory() {
  # Format Input
  format_dir="${@}"

  # Remove Directory From Store
  command egrep -s -v -x ".*:${format_dir}" $QCD_STORE > $QCD_TEMP

  # Store Removal Status
  rem_status=$?

  # Update Store If Successful
  update_store $rem_status
}

function remove_symbolic_link() {
  # Format Input
  format_link="${@%/}"

  # Remove Link From Store
  command egrep -s -v -x "${format_link}:.*" $QCD_STORE > $QCD_TEMP

  # Store Removal Status
  rem_status=$?

  # Update Store If Successful
  update_store $?
}

# End Helper Functions-----------------------------------------------------------------------------------------------------------------------------------------------

function parse_option_flags() {
  # Get Argument Flag
  flag=${@:$#}

  # Check For Option Flags
  if [[ "${flag/--remember/$REMEMBER}" = "$REMEMBER" ]]
  then
    # Add Current Directory
    add_directory

    # Terminate Program
    return $OK
  elif [[ "${flag/--forget/$FORGET}" = "$FORGET" ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Remove Current Directory
      remove_directory "$(command pwd)/"
    else
      # Remove Symbolic Link
      remove_symbolic_link "${@:0:$#}"
    fi

    # Terminate Program
    return $OK
  elif [[ "${flag/--clean/$CLEAN}" = "$CLEAN" ]]
  then
    # Get Compressed Paths From Store File
    local paths=$(command cat $QCD_STORE | command awk -F ':' '{print $2}')

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Paths
    for path in $paths
    do
      # Remove Invalid Paths
      if [[ ! -e "$path" ]]
      then
        remove_directory "$path"
      fi
    done

    # Unset IFS
    unset IFS

    # Terminate Program
    return $OK
  fi

  # Continue Program
  return $CONT
}

function parse_standalone_flags() {
  # Get Argument Flag
  flag=${@:$#}

  # Check For Standalone Flags
  if [[ "${flag/--help/$HELP}" = "$HELP" ]]
  then
    # Print Help
    command cat $QCD_HELP

    # Terminate Program
    return $OK
  elif [[ "${flag/--version/$VERSION}" = "$VERSION" ]]
  then
    # Print Version
    command cat $QCD_HELP | command head -n1

    # Terminate Program
    return $OK
  elif [[ "${flag/--update/$UPDATE}" = "$UPDATE" ]]
  then
    # Prompt User For Confirmation
    command read -p "qcd: Confirm update [y/n]: " confirm

    # Determine Action
    if [[ "${confirm//Y/$YES}" == $YES ]]
    then
      # Verify Dependency
      command curl &> /dev/null

      # Check Return Value
      if [[ $? -eq $NFD ]]
      then
        # Display Prompt
        command echo -e "→ Curl dependency not installed"

        # Terminate Program
        return $NFD
      fi

      # Display Prompt
      command echo -en "→ Downloading update "

      # Get Release Link
      release_url=$(command curl -s -L $QCD_RELEASES | command egrep -s -o "https.*zipball.*")

      # Error Check Release Link
      if [[ ! $? -eq $OK || -z $release_url ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to resolve download link for update"

        # Terminate Program
        return $ERR
      fi

      # Download Release Program Files
      command curl -s -L "${release_url/\",/}" > $QCD_UPDATE

      # Error Check Update
      if [[ ! $? -eq $OK || ! -f $QCD_UPDATE ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to download update"

        # Terminate Program
        return $ERR
      fi

      # Display Prompt
      command echo -en "\r→ Installing updates "

      # Extract And Install Program Files
      command unzip -o -j $QCD_UPDATE -d $QCD_FOLD &> /dev/null

      # Error Check Installation
      if [[ ! $? -eq $OK ]]
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

  # Continue Program
  return $CONT
}

# End Argument Parser Functions--------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Create Store File
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # End Pre-Execution Validation-------------------------------------------------------------------------------------------------------------------------------------

  # Parse Arguments For Option Flags
  parse_option_flags $@

  # Check Function Return
  if [[ ! $? -eq $CONT ]]
  then
    # Terminate Program
    return $?
  fi

  # Parse Arguments For Standalone Flags
  parse_standalone_flags $@

  # Check Function Return
  if [[ ! $? -eq $CONT ]]
  then
    # Terminate Program
    return $?
  fi

  # End Argument Parsing---------------------------------------------------------------------------------------------------------------------------------------------

  # Store Command Line Arguments
  local indicated_dir="$@"

  # Check For Empty Input
  if [[ -z $indicated_dir ]]
  then
    # Set To Home Directory
    indicated_dir=~
  fi

  # Check For Compressed Back Directory
  if [[ $indicated_dir =~ ^[0-9]+\.\.$ ]]
  then
    # Get Back Directory Height
    local back_height=${indicated_dir:0:$((${#indicated_dir} - 2))}

    # Generate Expanded Back Directory
    local back_dir=$(command printf "%${back_height}s")

    # Set To Expanded Back Directory
    indicated_dir="${back_dir// /$HWD}"
  fi

  # End Input Formatting And Validation------------------------------------------------------------------------------------------------------------------------------

  # Determine If Directory Is Linked
  if [[ -e "$indicated_dir" ]]
  then
    # Change To Valid Directory
    command cd "$indicated_dir"

    # Add Current Directory
    (add_directory &)

    # Terminate Program
    return $OK
  else
    # Store Directory Link
    local link=$(command echo -e "$indicated_dir" | command cut -d '/' -f1)

    # Initialize Relative Subdirectory
    local sdir=""

    # Get Subdirectory If Non-Empty
    if [[ $indicated_dir == */* ]]
    then
      sdir=${indicated_dir:${#link} + 1}
    fi

    # Get Symbolic Linkages From Store File
    local resv=$(command egrep -s -x "$link.*:.*" $QCD_STORE 2> /dev/null)
    local resc=$(command echo -e "$resv" | command wc -l 2> /dev/null)

    # Check Result Count
    if [[ $resc -gt 1 ]]
    then
      # Reset Result Count
      resc=0

      # Initialize Path Match
      local mpath=""

      # Initialize Filtered Paths
      local fpaths=""

      # Initialize Ignore Boolean
      local ignore=$FALSE

      # Store Current Directory
      local cdir=$(command pwd)

      # Store Matching Absolute Paths
      local paths=$(command echo -e "$resv" | command awk -F ':' '{print $2}')

      # Set IFS
      local IFS=$'\n'

      # Iterate Over Paths
      for path in $paths
      do
        # Form Complete Path
        path="${path}${sdir}"

        # Validate Path
        if [[ -e "$path" && ! "${path%/}" = "${cdir%/}" ]]
        then
          # Determine Path Match
          if [[ $ignore -eq $FALSE && -z $mpath ]]
          then
            # Select Path
            mpath=$path
          else
            # Unselect Path
            ignore=$TRUE
            mpath=""
          fi

          # Add Path To Filtered List
          fpaths="${fpaths}${path}:"
          resc=$((resc + 1))
        fi
      done

      # Unset IFS
      unset IFS

      # List Matching Links
      if [[ -z $mpath ]]
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

        # Set IFS
        local IFS=$':'

        # Generate Path Options
        local cnt=1
        for path in $paths
        do
          # Format Path
          path=$(format_dir "$path")

          # Output Path As Option
          command printf "($cnt) ${path%/}\n" >> $QCD_TEMP
          cnt=$((cnt + 1))
        done

        # Unset IFS
        unset IFS

        # Display Prompt
        command cat $QCD_TEMP

        # Read User Input
        command read -p "Endpoint: " ept

        # Error Check Input Format
        if [[ -z $ept || ! $ept =~ ^[0-9]+$ ]]
        then
          # Terminate Program
          return $ERR
        fi

        # Error Check Input Range
        if [[ $ept -lt 1 ]]
        then
          # Set To Minimum Selection
          ept=1
        elif [[ $ept -gt $resc ]]
        then
          # Set To Maximum Selection
          ept=$resc
        fi

        # Set To Manually Selected Endpoint
        resv=$(command echo -e "$paths" | command cut -d ':' -f$ept)
      else
        # Set To Automatically Selected Endpoint
        resv=$mpath
      fi
    else
      # Set To Default Endpoint
      resv=$(command echo -e "$resv" | command cut -d ':' -f2)
    fi

    # End Path Resolution--------------------------------------------------------------------------------------------------------------------------------------------

    # Error Check Result
    if [[ -z $resv ]]
    then
      # Display Error
      command echo -e "qcd: Cannot link keyword to directory"

      # Terminate Program
      return $ERR
    elif [[ ! -e "$resv" ]]
    then
      # Check Result Count
      if [[ $resc -gt 1 ]]
      then
        # Print Separator
        command echo
      fi

      # Display Error
      command echo -e "qcd: $(format_dir "${resv%/}"): Directory does not exist"

      # Remove Current Directory
      (remove_directory "$resv" &)

      # Terminate Program
      return $ERR
    else
      # Switch To Linked Path
      command cd "$resv"

      # Validate Subdirectory
      if [[ ! -z $sdir && -e "$sdir" ]]
      then
        # Switch To Subdirectory
        command cd "$sdir"

        # Add Current Directory
        (add_directory &)
      fi

      # Terminate Program
      return $OK
    fi
  fi

  # End Path Navigation----------------------------------------------------------------------------------------------------------------------------------------------
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
    local LINK_ARG=$(command echo -e "$CURR_ARG" | command cut -d '/' -f1)
    local LINK_LEN=${#LINK_ARG}

    # Obtain Truncated Path
    local SUBS_LEN=$(command echo -e "$CURR_ARG" | command awk -F '/' '{print length($0)-length($NF)}')
    local SUBS_ARG=${CURR_ARG:0:$SUBS_LEN}
    SUBS_ARG=${SUBS_ARG:$LINK_LEN + 1}

    # Store Resolved Directories
    local RES_DIRS=""

    # Resolve Linked Directories
    if [[ ! -e "$CURR_ARG" ]]
    then
      # Store Compressed Linked Paths From Store File
      LINK_PATHS=$(command cat $QCD_STORE | command egrep -s -x "$LINK_ARG:.*" | command awk -F ':' '{print $2}' | command tr ' ' ':')

      # Iterate Over Linked Paths
      for LINK_PATH in $LINK_PATHS
      do
        # Form Resolved Directory
        RES_DIR="${LINK_PATH//:/ }${SUBS_ARG}"

        # Add Resolved Directory
        if [[ -e "$RES_DIR" ]]
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

      # Iterate Over Resolved Directories
      for RES_DIR in $RES_DIRS
      do
        # Get Linked Subdirectory
        SUB_DIR=$(command ls -F "${RES_DIR//:/ }" 2> /dev/null | command egrep -s -x ".*/" | command tr ' ' ':')

        # Add Subdirectory To List
        SUB_DIRS="${SUB_DIRS}${SUB_DIR} "
      done

      # Format Subdirectories
      SUB_DIRS=${SUB_DIRS////}

      # Add Linked Subdirectories
      for SUB_DIR in $SUB_DIRS
      do
        # Expand Symbols
        SUB_DIR=${SUB_DIR//:/ }

        # Generate Linked Subdirectory
        LINK_SUB="$LINK_ARG/$SUBS_ARG$SUB_DIR"

        # Append Completion Slash
        if [[ ! -e "${LINK_ARG//\\ / }" ]]
        then
          WORD_LIST+=("$LINK_SUB/")
        else
          WORD_LIST+=("$LINK_SUB")
        fi
      done

      # Set IFS For COMREPLY
      local IFS=$'\n'

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${WORD_LIST[@]}")" "$CURR_ARG" 2> /dev/null))
    fi
  else
    # Store Compressed Symbolic Links From Store File
    local QUICK_DIRS=$(command cat $QCD_STORE | command awk -F ':' '{printf $1 "/\n"}' | command tr ' ' ':')

    # Store Current Directory Data
    local CURR_DIR=$(command basename "$(command pwd)")
    local CURR_REM=$FALSE

    # Add Linked Directories
    for QUICK_DIR in $QUICK_DIRS
    do
      # Expand Symbols
      QUICK_DIR=${QUICK_DIR//:/ }

      # Filter Duplicate Directories
      if [[ ! -e "$QUICK_DIR" ]]
      then
        # Exlude Current Directory
        if [[ $CURR_REM -eq $FALSE && "${QUICK_DIR%/}" = "${CURR_DIR%/}" ]]
        then
          CURR_REM=$TRUE
        else
          WORD_LIST+=("$QUICK_DIR")
        fi
      fi
    done

    # Set IFS
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
  command complete -o nospace -o filenames -F _qcd_comp qcd
  # command complete -o nospace -o filenames -A directory -F _qcd_comp -X ".*" qcd

  # Cleanup Store File
  (qcd -c &)
fi

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
