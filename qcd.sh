#!/usr/bin/env bash

#Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Return Values
OK=0
ERR=1
CONT=2
NFD=127

# Boolean Values
TRUE=1
FALSE=0

# Embedded Values
NSET=0
MINP=4
TIMEOUT=10

# End Defined Numerical Constants------------------------------------------------------------------------------------------------------------------------------------

# Option Flags
LIST="-l"
CLEAN="-c"
FORGET="-f"
REMEMBER="-r"
MKDIRENT="-m"

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

function _get_pwd() {
  # Return Present Working Directory
  command echo -e "$(command pwd)/"
}

# End Get Functions--------------------------------------------------------------------------------------------------------------------------------------------------

function _format_dir() {
  # Check For Environment Variable
  if [[ ! -z $HOME ]]
  then
    # Return Compressed Path
    command echo -e ${@/$HOME/\~}
  else
    # Return Original Path
    command echo -e ${@}
  fi
}

function _escape_dir() {
  # Store Argument Directory
  local fdir="${@}"

  # Escape Space Characters
  fdir="${fdir//\\ / }"
  fdir="${fdir//\\/}"

  # Return Escaped Directory
  command echo -e "${fdir}"
}

function _escape_regex() {
  # Store Argument String
  local fstr="${@}"

  # Escape Regex Characters
  fstr="${fstr//\*/\\*}"
  fstr="${fstr//\?/\\?}"
  fstr="${fstr//\./\\.}"
  fstr="${fstr//\$/\\$}"

  # Return Escaped String
  command echo -e "${fstr}"
}

# End String Functions-----------------------------------------------------------------------------------------------------------------------------------------------

function _cleanup() {
  # Remove Link And Temp Files
  command rm ${QCD_LINKS} ${QCD_TEMP} 2> /dev/null
}

function _update_links() {
  # Store Symbolic Links In Link File
  command awk -F ':' '{print $1}' $QCD_STORE > $QCD_LINKS
}

function _update_store() {
  # Check Exit Status
  if [[ ${1} -eq $OK ]]
  then
    # Update Store File
    command mv $QCD_TEMP $QCD_STORE 2> /dev/null

    # Update Link File
    _update_links
  else
    # Remove Temp File
    command rm $QCD_TEMP 2> /dev/null
  fi
}

function _add_directory() {
  # Store Current Directory
  local pwd=$(_get_pwd)

  # Cache Directory If Unique
  if [[ ! "${pwd%/}" == "${HOME%/}" && -z $(command egrep -s -x ".*:${pwd}" $QCD_STORE) ]]
  then
    # Get Basename Of Current Directory
    local ept=$(command basename "${pwd}")

    # Append Directory Data To Store File
    command printf "${ept}:${pwd}\n" >> $QCD_STORE

    # Sort Store File In Place
    command sort -o $QCD_STORE -n -t ':' -k2 $QCD_STORE

    # Update Link File
    _update_links
  fi
}

function _remove_directory() {
  # Store Argument Directory
  local fdir=$(_escape_regex "${@}")

  # Remove Directory From Store File
  command egrep -s -v -x ".*:${fdir}" $QCD_STORE > $QCD_TEMP

  # Store Operation Status
  local status=${?}

  # Update Store File
  _update_store ${status}
}

function _remove_symbolic_link() {
  # Store Argument Link
  local flink=$(_escape_regex "${@%/}")

  # Remove Link From Store File
  command egrep -s -v -x "${flink}:.*" $QCD_STORE > $QCD_TEMP

  # Store Operation Status
  local status=${?}

  # Update Store File
  _update_store ${status}
}

# End Link Management Functions--------------------------------------------------------------------------------------------------------------------------------------

function _parse_option_flags() {
  # Store Argument Flag
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
      # Store Current Directory
      local pwd=$(_get_pwd)

      # Remove Current Directory
      (_remove_directory "${pwd}" &)
    else
      # Store Link Argument
      local ldir="${@:1:$(($# - 1))}"

      # Remove Symbolic Link
      (_remove_symbolic_link "${ldir}" &)
    fi

    # Terminate Program
    return $OK
  elif [[ "${flag/--clean/$CLEAN}" == "$CLEAN" ]]
  then
    # Store Paths From Store File
    local paths=$(command awk -F ':' '{print $2}' $QCD_STORE)

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Paths
    for path in ${paths}
    do
      # Remove Invalid Paths
      if [[ ! -d "${path}" ]]
      then
        _remove_directory "${path}"
      fi
    done

    # Unset IFS
    unset IFS

    # Terminate Program
    return $OK
  elif [[ "${flag/--mkdir/$MKDIRENT}" == "$MKDIRENT" ]]
  then
    # Verify Argument Count
    if [[ $# -lt 2 ]]
    then
      # Display Prompt
      command echo -e "qcd: Insufficient arguments"

      # Terminate Program
      return $ERR
    else
      # Get Path
      local path="${@:1:$(($# - 1))}"

      # Get Trailing Path
      local trail_path=$(command echo -e "${curr_arg}" | command awk -F '/' '{print $NF}')

      # Get Prefix Path
      local prefix_path=${path:0:$((${#path} - ${#trail_path}))}

      # Verify Prefix Path
      if [[ ! -z ${prefix_path} && ! -d "${prefix_path}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Invalid directory path"

        # Terminate Program
        return $ERR
      elif [[ -d "${path}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Directory already exists"

        # Terminate Program
        return $ERR
      fi
    fi

    # Create Directory At Location
    command mkdir "${path}"

    # QCD Into New Directory
    qcd "${path}"

    # Terminate Program
    return $OK
  elif [[ "${flag/--list/$LIST}" == "$LIST" ]]
  then
    # Display Prompt
    command echo -en "\rqcd: Generating link map..."

    # Store Linkages From Store File
    local linkages=$(qcd --clean && command cat $QCD_STORE)

    # Determine List Type
    if [[ $# -gt 1 ]]
    then
      # Initialize Search Phrase
      local sphrase="${@:1:$(($# - 1))}"

      # Expand Regex Characters
      sphrase=${sphrase//\*/\.\*}
      sphrase=${sphrase//\?/\.}

      # Filter Linkages By Search Phrase
      linkages=$(command echo -e "${linkages}"| command egrep -s -x "${sphrase%/}.*:.*" 2> /dev/null)
    fi

    # Error Check Linkages
    if [[ -z ${linkages} ]]
    then
      # Display Prompt
      command echo -e "\rqcd: No linkages found      "

      # Terminate Program
      return $ERR
    fi

    # Store Terminal Column Count
    local cols=$(tput cols)

    # Determine Max Link Length
    local max_link=$(command echo -e "${linkages}" | command awk -F ':' '{print $1}' | command awk '{print length}' | command sort -n | command tail -n1)

    # Error Check Link Length
    if [[ ${max_link} -lt $MINP ]]
    then
      max_link=$MINP
    fi

    # Format Header
    command printf "\r${W} %-${max_link}s  %-$((${cols} - ${max_link} - 3))s${N}\n" "Link" "Directory" > $QCD_TEMP

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linkages
    for linkage in ${linkages}
    do
      # Store Linkage Components
      local link=$(command echo -e "${linkage}" | command awk -F ':' '{print $1}')
      local path=$(command echo -e "${linkage}" | command awk -F ':' '{print $2}')

      # Format Linkage
      command printf " %-${max_link}s  %s\n" "${link}" "$(_format_dir "${path%/}")" >> $QCD_TEMP
    done

    # Unset IFS
    unset IFS

    # Display Prompt
    command cat $QCD_TEMP

    # Terminate Program
    return $OK
  fi

  # Continue Program
  return $CONT
}

function _parse_standalone_flags() {
  # Store Argument Flag
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
      # Verify Curl Dependency
      command curl &> /dev/null

      # Check Return Value
      if [[ ${?} -eq $NFD ]]
      then
        # Display Prompt
        command echo -e "→ Curl dependency not installed"

        # Terminate Program
        return $NFD
      fi

      # Display Prompt
      command echo -en "→ Downloading update "

      # Determine Release URL
      release_url=$(command curl --connect-timeout $TIMEOUT -s -L $QCD_RELEASES | command egrep -s -o "https.*zipball.*")

      # Error Check Release URL
      if [[ ${?} -ne $OK || -z ${release_url} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to resolve download link for update"

        # Terminate Program
        return $ERR
      fi

      # Download Release Contents
      command curl --connect-timeout $TIMEOUT -s -L "${release_url/\",/}" > $QCD_UPDATE

      # Error Check Release Contents
      if [[ ${?} -ne $OK || ! -f $QCD_UPDATE ]]
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
      if [[ ${?} -ne $OK ]]
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
      command source $QCD_FOLD/qcd.sh 2> /dev/null

      # Get Release Version
      release_version=$(command cat $QCD_HELP | command head -n1 | command awk '{print $4}')

      # Display Prompt
      command echo -e "\r→ Update complete    \n\nUpdated to ${release_version}"
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
  # Check For Store File
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # End Validation---------------------------------------------------------------------------------------------------------------------------------------------------

  # Parse Arguments For Option Flags
  _parse_option_flags ${@}

  # Store Operation Status
  local status=${?}

  # Check Function Return
  if [[ ${status} -ne $CONT ]]
  then
    return ${status}
  fi

  # Parse Arguments For Standalone Flags
  _parse_standalone_flags ${@}

  # Store Operation Status
  local status=${?}

  # Check Function Return
  if [[ ${status} -ne $CONT ]]
  then
    return ${status}
  fi

  # End Argument Parsing---------------------------------------------------------------------------------------------------------------------------------------------

  # Store Command Line Arguments
  local dir_arg="$@"

  # Check For Empty Input
  if [[ -z ${dir_arg} ]]
  then
    # Set To Home Directory
    dir_arg=~
  else
    # Check For Back Directory Pattern
    if [[ "${dir_arg}" =~ ^[0-9]+\.\.$ ]]
    then
      # Determine Back Directory Height
      local back_height=${dir_arg:0:$((${#dir_arg} - 2))}

      # Generate Expanded Back Directory
      local back_dir=$(command printf "%${back_height}s")

      # Override Commandline Arguments
      dir_arg="${back_dir// /$HWD}"
    else
      # Format Escaped Characters
      dir_arg=$(_escape_dir "${dir_arg}")
    fi
  fi

  # End Input Directory Formatting-----------------------------------------------------------------------------------------------------------------------------------

  # Determine If Directory Is Linked
  if [[ -d "${dir_arg}" ]]
  then
    # Change To Valid Directory
    command cd "${dir_arg}"

    # Add Current Directory
    (_add_directory &)

    # Terminate Program
    return $OK
  else
    # Store Directory Link
    local dlink=$(command echo -e "${dir_arg}" | command cut -d '/' -f1)

    # Define Relative Subdirectory
    local sdir=$ESTR

    # Store Linked Subdirectory If Valid
    if [[ "${dir_arg}" == */* ]]
    then
      sdir=${dir_arg:$((${#dlink} + 1))}
    fi

    # Escape Regex Characters
    dlink=$(_escape_regex "${dlink}")

    # End Input Directory Parsing------------------------------------------------------------------------------------------------------------------------------------

    # Define Linkage Parameters
    local pathv=$NSET

    # Check For Indirect Link Matching
    if [[ -z $(command egrep -s -x "^${dlink}$" $QCD_LINKS) ]]
    then
      # Initialize Parameters
      local i=0 slink=$ESTR

      # Check For Hidden Directory Prefix
      if [[ "${dir_arg}" == \.* ]]
      then
        # Override Parameters
        i=2; slink="$ESC$CWD"
      fi

      # Wildcard Symbolic Link
      for ((;i < ${#dlink}; i++))
      do
        # Get Character At Index
        local c=${dlink:${i}:1}

        # Append Wildcard
        slink="${slink}${c}.*"
      done

      # Set IFS
      local IFS=$'\n'

      # Get Sequence Matched Symbolic Linkages From Store File
      pathv=($(command printf "%s\n" $(command egrep -i -s -x "${slink}:.*" $QCD_STORE 2> /dev/null | command awk -F ':' '{print $2}')))
    else
      # Set IFS
      local IFS=$'\n'

      # Get Link Matched Symbolic Linkages From Store File
      pathv=($(command printf "%s\n" $(command egrep -s -x "${dlink}:.*" $QCD_STORE 2> /dev/null | command awk -F ':' '{print $2}')))
    fi

    # Initialize Path Count
    local pathc=${#pathv[@]}

    # End Linkage Acquisition----------------------------------------------------------------------------------------------------------------------------------------

    # Check Result Count
    if [[ ${pathc} -gt 1 ]]
    then
      # Define Matched Path
      local mpath=$ESTR

      # Store Current Directory
      local pwd=$(_get_pwd)

      # Initialize Filtered Paths
      local fpaths=()

      # Iterate Over Matched Paths
      for path in ${pathv[@]}
      do
        # Form Complete Path
        path=$(_escape_dir "${path}${sdir}")

        # Validate Path
        if [[ -d "${path}" && ! "${path%/}" == "${pwd%/}" ]]
        then
          # Set IFS
          local IFS=$'\n'

          # Add Filtered Path To List
          fpaths+=($(command printf "%s\n" "${path}"))
        fi
      done

      # Update Path Count
      pathc=${#fpaths[@]}

      # Check For Single Path
      if [[ ${pathc} -eq 1 ]]
      then
        mpath="${fpaths[@]}"
      fi

      # End Path Filtering-------------------------------------------------------------------------------------------------------------------------------------------

      # List Matching Links
      if [[ -z ${mpath} ]]
      then
        # Error Check Path Results
        if [[ -z ${fpaths} ]]
        then
          # Terminate Program
          return $OK
        fi

        # Display Prompt
        command echo -en "\rqcd: Generating option list..."

        # Generate Prompt
        command echo -e "\rqcd: Multiple paths linked to ${B}${dir_arg%/}${N}" > $QCD_TEMP

        # Generate Path Options
        local cnt=1
        for path in ${fpaths[@]}
        do
          # Format Path
          path=$(_format_dir "${path}")

          # Output Path As Option
          command printf "(${cnt}) ${path%/}\n" >> $QCD_TEMP

          # Increment Counter
          cnt=$((${cnt} + 1))
        done

        # Display Prompt
        command cat $QCD_TEMP

        # End Option View--------------------------------------------------------------------------------------------------------------------------------------------

        # Read User Input
        command read -p "Endpoint: " ept

        # Error Check Input Format
        if [[ -z ${ept} || ! ${ept} =~ ^[0-9]+$ ]]
        then
          # Terminate Program
          return $ERR
        fi

        # Error Check Input Range
        if [[ ${ept} -lt 1 ]]
        then
          # Set To Minimum Selection
          ept=1
        elif [[ ${ept} -gt ${pathc} ]]
        then
          # Set To Maximum Selection
          ept=${pathc}
        fi

        # End Option Verification And Correction---------------------------------------------------------------------------------------------------------------------

        # Set To Manually Selected Endpoint
        pathv="${fpaths[$((${ept} - 1))]}"
      else
        # Set To Automatically Selected Endpoint
        pathv=${mpath}
      fi
    fi

    # End Path Resolution--------------------------------------------------------------------------------------------------------------------------------------------

    # Error Check Result
    if [[ -z ${pathv} ]]
    then
      # Display Error
      command echo -e "qcd: Cannot resolve linkage to directory"

      # Terminate Program
      return $ERR
    elif [[ ! -d "${pathv}" ]]
    then
      # Check Result Count
      if [[ ${pathc} -gt 1 ]]
      then
        # Print Separator
        command echo
      fi

      # Display Error
      command echo -e "qcd: $(_format_dir "${pathv%/}"): Directory does not exist"

      # Remove Current Directory
      (_remove_directory "${pathv}" &)

      # Terminate Program
      return $ERR
    else
      # Switch To Linked Path
      command cd "${pathv}"

      # Validate Subdirectory
      if [[ ! -z ${sdir} && -d "${sdir}" ]]
      then
        # Switch To Subdirectory
        command cd "${sdir}"

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

  # Store Command Line Argument
  local curr_arg=${COMP_WORDS[1]}

  # Determine Completion Type
  if [[ "${curr_arg}" == */* ]]
  then
    # Obtain Symbolic Link
    local link_arg=$(command echo -e "${curr_arg}" | command cut -d '/' -f1)
    local link_len=${#link_arg}

    # Obtain Trailing Subdirectory Path
    local trail_arg=$(command echo -e "${curr_arg}" | command awk -F '/' '{print $NF}')

    # Obtain Leading Subdirectory Path
    local subs_len=$(command echo -e "${curr_arg}" | command awk -F '/' '{print length($0)-length($NF)}')
    local subs_arg=${curr_arg:0:${subs_len}}
    subs_arg=${subs_arg:${link_len} + 1}

    # End Input Parsing----------------------------------------------------------------------------------------------------------------------------------------------

    # Resolve Linked Directories
    if [[ ! -d "${curr_arg}" ]]
    then
      # Initialize Link Paths
      local local_paths=$NSET

      # Check For Indirect Link Matching
      if [[ -z $(command egrep -s -x "^${link_arg}$" $QCD_LINKS) ]]
      then
        # Initialize Parameters
        local i=0 slink_arg=$ESTR

        # Check For Hidden Directory Prefix
        if [[ "${link_arg}" == \.* ]]
        then
          # Override Parameters
          i=1; slink_arg="$ESC$CWD"
        fi

        # Wildcard Symbolic Link
        for ((;i < ${#link_arg}; i++))
        do
          # Get Character At Index
          local c=${link_arg:${i}:1}

          # Append Wildcard
          slink_arg="${slink_arg}${c}.*"
        done

        # Set IFS
        local IFS=$'\n'

        # Get Sequence Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -i -x "${slink_arg}:.*" $QCD_STORE | command awk -F ':' '{print $2}')))
      else
        # Set IFS
        local IFS=$'\n'

        # Get Link Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -x "${link_arg}:.*" $QCD_STORE | command awk -F ':' '{print $2}')))
      fi

      # End Linkage Acquisition--------------------------------------------------------------------------------------------------------------------------------------

      # Set IFS
      local IFS=$'\n'

      # Initialize Resolved Directories
      local res_dirs=()

      # Iterate Over Linked Paths
      for link_path in ${link_paths[@]}
      do
        # Form Resolved Directory
        local res_dir=$(_escape_dir "${link_path}${subs_arg}")

        # Add Resolved Directory
        if [[ -d "${res_dir}" ]]
        then
          # Add Resolved Directory To List
          res_dirs+=($(command printf "%s\n" "${res_dir}"))
        fi
      done
    else
      # Resolve Local Directories
      res_dirs=$(_escape_dir "${curr_arg}")
    fi

    # End Path Resolution--------------------------------------------------------------------------------------------------------------------------------------------

    # Error Check Resolved Directory
    if [[ ! -z ${res_dirs} ]]
    then
      # Initialize Subdirectories
      local sub_dirs=()

      # Iterate Over Resolved Directories
      for res_dir in ${res_dirs[@]}
      do
        # Set IFS
        local IFS=$'\n'

        # Add Linked Subdirectories Of Similar Visibility
        if [[ ! "${trail_arg:0:1}" == "$CWD" ]]
        then
          # Add Compressed Visible Linked Subdirectories
          sub_dirs+=($(command printf "%s\n" $(command ls -F "${res_dir}" 2> /dev/null | command egrep -s -x ".*/")))
        else
          # Add Compressed Linked Subdirectories
          sub_dirs+=($(command printf "%s\n" $(command ls -aF "${res_dir}" 2> /dev/null | command egrep -s -x ".*/")))
        fi
      done

      # End Subdirectory Acquisition---------------------------------------------------------------------------------------------------------------------------------

      # Set IFS
      local IFS=$'\n'

      # Format Symbolic Link
      link_arg="${link_arg}/"

      # Add Linked Subdirectories
      for sub_dir in ${sub_dirs[@]}
      do
        # Generate Linked Subdirectory
        link_sub=$(_escape_dir "${link_arg}${subs_arg}${sub_dir////}")

        # Add Linked Subdirectories
        if [[ ! -d "${link_sub}" ]]
        then
          word_list+=("${link_sub}/")
        else
          word_list+=("${link_sub}")
        fi
      done

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${word_list[@]}")" "${curr_arg}" 2> /dev/null))

      # End Option Generation----------------------------------------------------------------------------------------------------------------------------------------
    fi
  else
    # Get Symbolic Links From Store File
    local quick_dirs=$(command awk -F ':' '{printf $1 "/\n"}' $QCD_STORE)

    # Store Current Directory Data
    local pres_dir=$(command basename "$(_get_pwd)")

    # Initialize Ignore Boolean
    local curr_rem=$FALSE

    # End Linkage Acquisition----------------------------------------------------------------------------------------------------------------------------------------

    # Set IFS
    local IFS=$'\n'

    # Add Linked Directories
    for quick_dir in ${quick_dirs}
    do
      # Filter Symbolic Links
      if [[ ! -d "${quick_dir}" ]]
      then
        if [[ ${curr_rem} -eq $FALSE && "${quick_dir%/}" == "${pres_dir%/}" ]]
        then
          # Exlude Current Directory
          curr_rem=$TRUE
        elif [[ "${curr_arg:0:1}" == "$CWD" && "${quick_dir:0:1}" == "$CWD" || ! "${curr_arg:0:1}" == "$CWD" && ! "${quick_dir:0:1}" == "$CWD" ]]
        then
          # Add Symbolic Links Of Similar Visibility
          word_list+=("${quick_dir}")
        fi
      fi
    done

    # Set Completion List
    COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${word_list[@]}")" "${curr_arg}" 2> /dev/null))

    # End Option Generation------------------------------------------------------------------------------------------------------------------------------------------
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
    command trap _cleanup EXIT &> /dev/null

    # Set Environment To Show Visible Files
    command bind 'set match-hidden-files off' &> /dev/null

    # Initialize Completion Engine
    command complete -o nospace -o filenames -A directory -F _qcd_comp qcd
  fi
}

# Initialize QCD
_qcd_init

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
