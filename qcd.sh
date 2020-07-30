#!/usr/bin/env bash

#Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Return Values
OK=0
ERR=1
CONT=2
NFD=127

# Embedded Values
MINP=4
TIMEOUT=10

# Conditional Values
TRUE=1
FALSE=0

# End Defined Numerical Constants------------------------------------------------------------------------------------------------------------------------------------

# Option Flags
LIST="-l"
CLEAN="-c"
FORGET="-f"
REMEMBER="-r"

# Standalone Flags
HELP="-h"
UPDATE="-u"
VERSION="-v"

# Embedded Strings
ESTR=""
YES="y"
ESC="\\"

# Directory Patterns
CWD="."
HWD="../"

# Text Formatting Strings
B=$(command tput bold)
N=$(command tput sgr0)
W=$(tput setaf 0)$(tput setab 7)

# End Defined String Constants---------------------------------------------------------------------------------------------------------------------------------------

# Program Files
QCD_FOLD=~/.qcd
QCD_HELP=$QCD_FOLD/help
QCD_TEMP=$QCD_FOLD/temp
QCD_LINKS=$QCD_FOLD/links
QCD_STORE=$QCD_FOLD/store
QCD_UPDATE=$QCD_FOLD/update.zip

# Release URL
QCD_RELEASES="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End Defined Program Constants--------------------------------------------------------------------------------------------------------------------------------------

function _format_dir() {
  # Compress Home Directory
  command echo -e ${@/$HOME/\~}
}

function _escape_dir() {
  # Store Argument Directory
  local fdir="$@"

  # Escape Characters
  fdir="${fdir//\\ / }"
  fdir="${fdir//\\/}"

  # Return Escaped Directory
  command echo -e "$fdir"
}

function _escape_regex() {
  # Store Argument String
  local fstr="$@"

  # Escape Regex Characters
  fstr="${fstr//\*/\\*}"
  fstr="${fstr//\?/\\?}"
  fstr="${fstr//\./\\.}"

  # Return Escaped String
  command echo -e "$fstr"
}

# End String Functions-----------------------------------------------------------------------------------------------------------------------------------------------

function _cleanup() {
  # Delete Link And Temp Files
  command rm $QCD_LINKS $QCD_TEMP 2> /dev/null
}

function _update_links() {
  # Store Symbolic Links In Link File
  command cat $QCD_STORE | command awk -F ':' '{print $1}' > $QCD_LINKS
}

function _update_store() {
  # Check Exit Status
  if [[ $1 -eq $OK ]]
  then
    # Update Store File
    command mv $QCD_TEMP $QCD_STORE

    # Update Symbolic Link File
    _update_links
  else
    # Remove Temp File
    command rm $QCD_TEMP 2> /dev/null
  fi
}

function _add_directory() {
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

    # Update Symbolic Link File
    _update_links
  fi
}

function _remove_directory() {
  # Format Input
  local format_dir=$(_escape_regex "${@}")

  # Remove Directory From Store
  command egrep -s -v -x ".*:${format_dir}" $QCD_STORE > $QCD_TEMP

  # Store Operation Status
  local status=$?

  # Update Store If Successful
  _update_store $status
}

function _remove_symbolic_link() {
  # Format Input
  local format_link=$(_escape_regex "${@%/}")

  # Remove Link From Store
  command egrep -s -v -x "${format_link}:.*" $QCD_STORE > $QCD_TEMP

  # Store Operation Status
  local status=$?

  # Update Store If Successful
  _update_store $status
}

# End Symbolic Link Management Functions-----------------------------------------------------------------------------------------------------------------------------

function _parse_option_flags() {
  # Get Argument Flag
  local flag="${@:$#}"

  # Check For Option Flags
  if [[ "${flag/--remember/$REMEMBER}" == "$REMEMBER" ]]
  then
    # Add Current Directory
    (_add_directory &)

    # Terminate Program
    return $OK
  elif [[ "${flag/--forget/$FORGET}" == "$FORGET" ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Remove Current Directory
      (_remove_directory "$(command pwd)/" &)
    else
      # Remove Symbolic Link
      (_remove_symbolic_link "${@:1:$(($# - 1))}" &)
    fi

    # Terminate Program
    return $OK
  elif [[ "${flag/--list/$LIST}" == "$LIST" ]]
  then
    # Display Prompt
    command echo -en "\rqcd: Generating link map..."

    # Get Linkages From Store File
    local linkages=$(qcd --clean && command cat $QCD_STORE)

    # Determine List Type
    if [[ $# -gt 1 ]]
    then
      # Define Search Phrase
      local sphrase="${@:1:$(($# - 1))}"

      # Expand Regex Characters
      sphrase=${sphrase//\*/\.\*}
      sphrase=${sphrase//\?/\.}

      # Retain Matching Linkages
      linkages=$(command echo -e "$linkages"| command egrep -s -x "${sphrase%/}.*:.*" 2> /dev/null)
    fi

    # Error Check Linkages
    if [[ -z $linkages ]]
    then
      # Display Prompt
      command echo -e "\rqcd: No linkages found      "

      # Terminate Program
      return $ERR
    fi

    # Get Terminal Column Count
    local cols=$(tput cols)

    # Get Max Link Length
    local max_link=$(command echo -e "$linkages" | command awk -F ':' '{print $1}' | command awk '{print length}' | command sort -n | command tail -n1)

    # Error Check Max Link Length
    if [[ $max_link -lt $MINP ]]
    then
      # Set To Minimum Padding
      max_link=$MINP
    fi

    # Format Header
    command printf "\r${W} %-${max_link}s %-$(($cols - $max_link - 2))s${N}\n" "Link" "Directory" > $QCD_TEMP

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linkages From Store File
    for linkage in $linkages
    do
      # Get Linkage Components
      local link=$(command echo -e "$linkage" | command awk -F ':' '{print $1}')
      local path=$(command echo -e "$linkage" | command awk -F ':' '{print $2}')

      # Format Linkage
      command printf " %-${max_link}s  %s\n" $link $(_format_dir "${path%/}") >> $QCD_TEMP
    done

    # Unset IFS
    unset IFS

    # Display Prompt
    command cat $QCD_TEMP

    # Terminate Program
    return $OK
  elif [[ "${flag/--clean/$CLEAN}" == "$CLEAN" ]]
  then
    # Get Paths From Store File
    local paths=$(command cat $QCD_STORE | command awk -F ':' '{print $2}')

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Paths
    for path in $paths
    do
      # Remove Invalid Paths
      if [[ ! -e "$path" ]]
      then
        _remove_directory "$path"
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

function _parse_standalone_flags() {
  # Get Argument Flag
  local flag="${@:$#}"

  # Check For Standalone Flags
  if [[ "${flag/--help/$HELP}" == "$HELP" ]]
  then
    # Print Help
    command cat $QCD_HELP

    # Terminate Program
    return $OK
  elif [[ "${flag/--version/$VERSION}" == "$VERSION" ]]
  then
    # Print Version
    command cat $QCD_HELP | command head -n1

    # Terminate Program
    return $OK
  elif [[ "${flag/--update/$UPDATE}" == "$UPDATE" ]]
  then
    # Prompt User For Confirmation
    command read -p "qcd: Confirm update [y/n]: " confirm

    # Determine Action
    if [[ "${confirm//Y/$YES}" == "$YES" ]]
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
      release_url=$(command curl --connect-timeout $TIMEOUT -s -L $QCD_RELEASES | command egrep -s -o "https.*zipball.*")

      # Error Check Release Link
      if [[ $? -ne $OK || -z $release_url ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to resolve download link for update"

        # Terminate Program
        return $ERR
      fi

      # Download Release Program Files
      command curl --connect-timeout $TIMEOUT -s -L "${release_url/\",/}" > $QCD_UPDATE

      # Error Check Update
      if [[ $? -ne $OK || ! -f $QCD_UPDATE ]]
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
      if [[ $? -ne $OK ]]
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

      # Get Update Version
      update_version=$(command cat $QCD_HELP | command head -n1 | command awk '{print $4}')

      # Display Prompt
      command echo -e "\r→ Update complete    \n\nUpdated to $update_version"
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

  # End Validation---------------------------------------------------------------------------------------------------------------------------------------------------

  # Parse Arguments For Option Flags
  _parse_option_flags $@

  # Store Operation Status
  local status=$?

  # Check Function Return
  if [[ $status -ne $CONT ]]
  then
    # Terminate Program
    return $status
  fi

  # Parse Arguments For Standalone Flags
  _parse_standalone_flags $@

  # Store Operation Status
  local status=$?

  # Check Function Return
  if [[ $status -ne $CONT ]]
  then
    # Terminate Program
    return $status
  fi

  # End Argument Parsing---------------------------------------------------------------------------------------------------------------------------------------------

  # Store Command Line Arguments
  local indicated_dir="$@"

  # Check For Empty Input
  if [[ -z $indicated_dir ]]
  then
    # Set To Home Directory
    indicated_dir=~
  else
    # Format Escaped Characters
    indicated_dir=$(_escape_dir "$indicated_dir")

    # Check For Compressed Back Directory
    if [[ "$indicated_dir" =~ ^[0-9]+\.\.$ ]]
    then
      # Get Back Directory Height
      local back_height=${indicated_dir:0:$((${#indicated_dir} - 2))}

      # Generate Expanded Back Directory
      local back_dir=$(command printf "%${back_height}s")

      # Set To Expanded Back Directory
      indicated_dir="${back_dir// /$HWD}"
    fi
  fi

  # End Input Formatting---------------------------------------------------------------------------------------------------------------------------------------------

  # Determine If Directory Is Linked
  if [[ -e "$indicated_dir" ]]
  then
    # Change To Valid Directory
    command cd "$indicated_dir"

    # Add Current Directory
    (_add_directory &)

    # Terminate Program
    return $OK
  else
    # Store Directory Link
    local dlink=$(command echo -e "$indicated_dir" | command cut -d '/' -f1)

    # Initialize Relative Subdirectory
    local sdir=$ESTR

    # Get Subdirectory If Non-Empty
    if [[ "$indicated_dir" == */* ]]
    then
      # Slice From First Forward Slash
      sdir=${indicated_dir:$((${#dlink} + 1))}
    fi

    # Escape Regex Characters
    dlink=$(_escape_regex "$dlink")

    # Initialize Symbolic Linkages
    local resv=$ESTR

    # Check For Indirect Link Matching
    if [[ -z $(command cat $QCD_LINKS | command grep "^$dlink$") ]]
    then
      # Initialize Counter
      local i=0

      # Initialize New Link
      local nlink=$ESTR

      # Check For Hidden Directory Prefix
      if [[ "$indicated_dir" == \.* ]]
      then
        # Override New Link
        nlink="$ESC$CWD"

        # Shift Counter
        i=2
      fi

      # Wildcard Symbolic Link
      for ((;i < ${#dlink}; i++))
      do
        # Get Character At Index
        local c=${dlink:$i:1}

        # Append Wildcard
        nlink="${nlink}${c}.*"
      done

      # Get Case Insensitive Symbolic Linkages From Store File
      resv=$(command egrep -s -i -x "$nlink:.*" $QCD_STORE 2> /dev/null)
    else
      # Get Case Sensitive Symbolic Linkages From Store File
      resv=$(command egrep -s -x "$dlink:.*" $QCD_STORE 2> /dev/null)
    fi

    # Get Count Of Symbolic Linkages
    local resc=$(command echo -e "$resv" | command wc -l 2> /dev/null)

    # Check Result Count
    if [[ $resc -gt 1 ]]
    then
      # Reset Result Count
      resc=0

      # Initialize Path Match
      local mpath=$ESTR

      # Initialize Filtered Paths
      local fpaths=$ESTR

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
        path=$(_escape_dir "${path}${sdir}")

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
            mpath=$ESTR
          fi

          # Add Path To Filtered List
          fpaths="${fpaths}${path}:"
          resc=$(($resc + 1))
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
        command echo -en "\rqcd: Generating option list..."

        # Generate Prompt
        command echo -e "\rqcd: Multiple paths linked to ${B}${indicated_dir%/}${N}" > $QCD_TEMP

        # Set IFS
        local IFS=$':'

        # Generate Path Options
        local cnt=1
        for path in $paths
        do
          # Format Path
          path=$(_format_dir "$path")

          # Output Path As Option
          command printf "($cnt) ${path%/}\n" >> $QCD_TEMP
          cnt=$(($cnt + 1))
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
      command echo -e "qcd: $(_format_dir "${resv%/}"): Directory does not exist"

      # Remove Current Directory
      (_remove_directory "$resv" &)

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
        (_add_directory &)
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
  local word_list=()

  # Store Current Commandline Argument
  local curr_arg=${COMP_WORDS[1]}

  # Path Completion
  if [[ "$curr_arg" == */* ]]
  then
    # Obtain Symbolic Link
    local link_arg=$(command echo -e "$curr_arg" | command cut -d '/' -f1)
    local link_len=${#link_arg}

    # Obtain Trailing Subdirectory Path
    local trail_arg=$(command echo -e "$curr_arg" | command awk -F '/' '{print $NF}')

    # Obtain Leading Subdirectory Path
    local subs_len=$(command echo -e "$curr_arg" | command awk -F '/' '{print length($0)-length($NF)}')
    local subs_arg=${curr_arg:0:$subs_len}
    subs_arg=${subs_arg:$link_len + 1}

    # Store Resolved Directories
    local res_dirs=$ESTR

    # Resolve Linked Directories
    if [[ ! -e "$curr_arg" ]]
    then
      # Initialize Local Paths
      local local_paths=$ESTR

      # Check For Indirect Link Matching
      if [[ -z $(command cat $QCD_LINKS | command grep "^$link_arg$") ]]
      then
        # Initialize Counter
        local i=0

        # Initialize New Link
        local nlink=$ESTR

        # Check For Hidden Directory Prefix
        if [[ "$link_arg" == \.* ]]
        then
          # Override New Link
          nlink="$ESC$CWD"

          # Shift Counter
          i=1
        fi

        # Wildcard Symbolic Link
        for ((;i < ${#link_arg}; i++))
        do
          # Get Character At Index
          local c=${link_arg:$i:1}

          # Append Wildcard
          nlink="${nlink}${c}.*"
        done

        # Get Compressed Case Insensitive Linked Paths From Store File
        local link_paths=$(command egrep -s -i -x "$nlink:.*" $QCD_STORE | command awk -F ':' '{print $2}' | command tr ' ' ':')
      else
        # Get Compressed Case Sensitive Linked Paths From Store File
        local link_paths=$(command egrep -s -x "$link_arg:.*" $QCD_STORE | command awk -F ':' '{print $2}' | command tr ' ' ':')
      fi

      # Iterate Over Linked Paths
      for link_path in $link_paths
      do
        # Form Resolved Directory
        local res_dir=$(_escape_dir "${link_path//:/ }${subs_arg}")

        # Add Resolved Directory
        if [[ -e "$res_dir" ]]
        then
          res_dirs="${res_dirs}${res_dir// /:} "
        fi
      done
    else
      # Resolve Local Directories
      res_dirs="$curr_arg"
    fi

    # Error Check Resolved Directory
    if [[ ! -z $res_dirs ]]
    then
      # Initialize Subdirectories
      local sub_dirs=$ESTR

      # Iterate Over Resolved Directories
      for res_dir in $res_dirs
      do
        # Initialize Subdirectory
        local sub_dir=$ESTR

        # Add Linked Subdirectories Of Similar Visibility
        if [[ ! "${trail_arg:0:1}" == "$CWD" ]]
        then
          # Get Visible Linked Subdirectory
          sub_dir=$(command ls -F "${res_dir//:/ }" 2> /dev/null | command egrep -s -x ".*/" | command tr ' ' ':')
        else
          # Get Hidden Linked Subdirectory
          sub_dir=$(command ls -aF "${res_dir//:/ }" 2> /dev/null | command egrep -s -x ".*/" | command tr ' ' ':')
        fi

        # Add Subdirectory To List
        sub_dirs="${sub_dirs}${sub_dir} "
      done

      # Format Symbolic Link
      link_arg="${link_arg}/"

      # Format Subdirectories
      sub_dirs=${sub_dirs////}

      # Add Linked Subdirectories
      for sub_dir in $sub_dirs
      do
        # Expand Symbols
        sub_dir=${sub_dir//:/ }

        # Generate Linked Subdirectory
        link_sub="${link_arg}${subs_arg}${sub_dir}"

        # Add Linked Subdirectories
        if [[ ! -e "$(_escape_dir "$link_sub")" ]]
        then
          word_list+=("$link_sub/")
        else
          word_list+=("$link_sub")
        fi
      done

      # Set IFS
      local IFS=$'\n'

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${word_list[@]}")" "$curr_arg" 2> /dev/null))
    fi
  else
    # Store Compressed Symbolic Links From Store File
    local quick_dirs=$(command cat $QCD_STORE | command awk -F ':' '{printf $1 "/\n"}' | command tr ' ' ':')

    # Store Current Directory Data
    local curr_dir=$(command basename "$(command pwd)")
    local curr_rem=$FALSE

    # Add Linked Directories
    for quick_dir in $quick_dirs
    do
      # Expand Symbols
      quick_dir=${quick_dir//:/ }

      # Filter Symbolic Links
      if [[ ! -e "$quick_dir" ]]
      then
        if [[ $curr_rem -eq $FALSE && "${quick_dir%/}" = "${curr_dir%/}" ]]
        then
          # Exlude Current Directory
          curr_rem=$TRUE
        elif [[ "${curr_arg:0:1}" == "$CWD" && "${quick_dir:0:1}" == "$CWD" || ! "${curr_arg:0:1}" == "$CWD" && ! "${quick_dir:0:1}" == "$CWD" ]]
        then
          # Add Symbolic Links Of Similar Visibility
          word_list+=("$quick_dir")
        fi
      fi
    done

    # Set IFS
    local IFS=$'\n'

    # Set Completion List
    COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${word_list[@]}")" "$curr_arg" 2> /dev/null))
  fi
}

# End QCD Completion Function----------------------------------------------------------------------------------------------------------------------------------------

function _qcd_init() {
  # Initialize QCD
  if [[ -f $QCD_STORE ]]
  then
    # Clean Store File
    (qcd --clean &)

    # Populate Link File
    (_update_links &)

    # Cleanup Files On Exit
    command trap _cleanup EXIT

    # Set Environment To Show Visible Files
    command bind 'set match-hidden-files off' 2> /dev/null

    # Initialize Completion Engine
    command complete -o nospace -o filenames -A directory -F _qcd_comp qcd
  fi
}

# Initialize QCD
_qcd_init

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
