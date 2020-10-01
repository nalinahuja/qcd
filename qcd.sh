#!/usr/bin/env bash

# Developed by Nalin Ahuja, nalinahuja22

# TODO, selectable menu
# TODO, speed improvements
# TODO, refactor codebase
# TODO, remember flag custom path
# TODO, completion engine cleanup and optimization
# TODO, update routine using wget (README)
# TODO, add declare keyword instead of NSET and ESTR
# TODO, network interface functions

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# TODO: CLEAN UP THIS SHIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Default Values
NSET=0

# Boolean Values
TRUE=1
FALSE=0

# Embedded Values
MINP=4
TOUT=10

# Return Values
OK=0
ERR=1
CONT=2
NFD=127

# End Defined Numerical Constants------------------------------------------------------------------------------------------------------------------------------------

# TODO: CLEAN UP THIS SHIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Default Values
ESTR=""

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
YES="y"
QUIT="q"
BSLH="\\"

# Directory Patterns
CWD="."
HWD="../"

# Text Formatting Strings
B=$(command tput bold)
N=$(command tput sgr0)
W=$(command tput setaf 0)$(command tput setab 7)

# End Defined String Constants---------------------------------------------------------------------------------------------------------------------------------------

# Program Files
QCD_FOLD=~/.qcd
QCD_HELP=$QCD_FOLD/help
QCD_TEMP=$QCD_FOLD/temp
QCD_LINKS=$QCD_FOLD/links
QCD_STORE=$QCD_FOLD/store
QCD_UPDATE=$QCD_FOLD/update

# Release URL
QCD_RELEASES="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End Defined Program Constants--------------------------------------------------------------------------------------------------------------------------------------

function _get_pwd() {
  # Return Present Working Directory
  command echo -e "$(command pwd)/"
}

function _split_path() {
  # Return Absolute Path Of Linkage
  command echo -e "${@#*:}"
}

function _format_dir() {
  # Check For Environment Variable
  if [[ ! -z ${HOME} ]]
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

# End Utility Functions----------------------------------------------------------------------------------------------------------------------------------------------

function _update_links() {
  # Store Symbolic Links In Link File
  command awk -F ':' '{print $1}' ${QCD_STORE} > ${QCD_LINKS}
}

function _update_store() {
  # Check Exit Status
  if [[ ${1} -eq ${OK} ]]
  then
    # Update Store File
    command mv ${QCD_TEMP} ${QCD_STORE} 2> /dev/null

    # Update Link File
    _update_links
  else
    # Remove Temp File
    command rm ${QCD_TEMP} 2> /dev/null
  fi
}

function _verify_files() {
  # Check For Store File
  if [[ ! -f ${QCD_STORE} ]]
  then
    # Create Store File
    command touch ${QCD_STORE}
  fi

  # Check For Link File
  if [[ ! -f ${QCD_LINKS} ]]
  then
    # Create Link File
    _update_links
  fi
}

function _cleanup_files() {
  # Remove Link And Temp Files
  command rm ${QCD_LINKS} ${QCD_TEMP} 2> /dev/null
}

# End File Management Functions--------------------------------------------------------------------------------------------------------------------------------------

function _add_directory() {
  # Store Current Path
  local abs_path=$(_get_pwd)

  # Check For Argument Path
  if [[ $# -gt 0 ]]
  then
    # Store Argument Path
    abs_path=$(command realpath "${@}")
  fi

  # Store Directory If Unique
  if [[ ! "${abs_path%/}" == "${HOME%/}" && -z $(command egrep -s -x ".*:${abs_path}" ${QCD_STORE} 2> /dev/null) ]]
  then
    # Store Basename Of Path
    local ept=$(command basename "${abs_path}")

    # Append Data To Store File
    command printf "${ept}:${abs_path}\n" >> ${QCD_STORE}

    # Sort Store File In Place
    command sort -o ${QCD_STORE} -n -t ':' -k2 ${QCD_STORE}

    # Update Link File
    _update_links
  fi
}

function _remove_directory() {
  # Store Current Path
  local rdir=$(_get_pwd)

  # Check For Override Path
  if [[ $# -gt 0 ]]
  then
    # Store Indicated Directory Path
    rdir=$(_escape_regex "${@}")
  fi

  # Remove Directory From Store File
  command egrep -s -v -x ".*:${rdir}" ${QCD_STORE} > ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}
}

function _remove_symbolic_link() {
  # Store Argument Link
  local rlink=$(_escape_regex "${@%/}")

  # Remove Link From Store File
  command egrep -s -v -x "${rlink}:.*" ${QCD_STORE} > ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}
}

# End Link Management Functions--------------------------------------------------------------------------------------------------------------------------------------

# TODO: ADD SELECTION INTERFACE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# End Selection Interface Functions----------------------------------------------------------------------------------------------------------------------------------

# TODO: CLEAN UP THIS SHIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

function _parse_option_flags() {
  # Store Argument Flag
  local flag="${@:$#}"

  # Check For Option Flags
  if [[ "${flag/--remember/${REMEMBER}}" == "${REMEMBER}" ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Add Current Directory
      (_add_directory &)
    else
      # Store Path Argument
      local lpath="${@:1:$(($# - 1))}"

      # Add Indicated Path
      (_add_directory "${lpath}" &)
    fi

    # Terminate Program
    return ${OK}
  elif [[ "${flag/--forget/${FORGET}}" == "${FORGET}" ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Remove Current Directory
      (_remove_directory &)
    else
      # Store Link Argument
      local ldir="${@:1:$(($# - 1))}"

      # Remove Symbolic Link
      (_remove_symbolic_link "${ldir}" &)
    fi

    # Terminate Program
    return ${OK}
  elif [[ "${flag/--clean/${CLEAN}}" == "${CLEAN}" ]]
  then
    # Store Paths From Store File
    local paths=$(command awk -F ':' '{print $2}' ${QCD_STORE})

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
    return ${OK}
  elif [[ "${flag/--mkdir/${MKDIRENT}}" == "${MKDIRENT}" ]]
  then
    # Verify Argument Count
    if [[ $# -lt 2 ]]
    then
      # Display Prompt
      command echo -e "qcd: Insufficient arguments"

      # Terminate Program
      return ${ERR}
    else
      # Get Path
      local path="${@:1:$(($# - 1))}"

      # Get Trailing Path
      local trail_path=$(command basename "${path}")

      # Get Prefix Path
      local prefix_path="${path:0:$((${#path} - ${#trail_path}))}"

      # Verify Path Components
      if [[ -d "${path%/}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Directory already exists"

        # Terminate Program
        return ${ERR}
      elif [[ ! -z ${prefix_path} && ! -d "${prefix_path%/}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Invalid path to new directory"

        # Terminate Program
        return ${ERR}
      fi
    fi

    # Create Directory At Location
    command mkdir "${path}"

    # QCD Into New Directory
    qcd "${path}"

    # Terminate Program
    return ${OK}
  elif [[ "${flag/--list/${LIST}}" == "${LIST}" ]]
  then
    # Display Prompt
    command echo -en "\rqcd: Generating link map..."

    # Store Linkages From Store File
    local linkages=$(qcd --clean && command cat ${QCD_STORE})

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
      return ${ERR}
    fi

    # Store Terminal Column Count
    local cols=$(command tput cols)

    # Determine Max Link Length
    local max_link=$(command echo -e "${linkages}" | command awk -F ':' '{print $1}' | command awk '{print length}' | command sort -n | command tail -n1)

    # Error Check Link Length
    if [[ ${max_link} -lt ${MINP} ]]
    then
      max_link=${MINP}
    fi

    # Format Header
    command printf "\r${W} %-${max_link}s  %-$((${cols} - ${max_link} - 3))s${N}\n" "Link" "Directory" > ${QCD_TEMP}

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linkages
    for linkage in ${linkages}
    do
      # Store Linkage Components
      local link=$(command echo -e "${linkage}" | command awk -F ':' '{print $1}')
      local path=$(command echo -e "${linkage}" | command awk -F ':' '{print $2}')

      # Format Linkage
      command printf " %-${max_link}s  %s\n" "${link}" "$(_format_dir "${path%/}")" >> ${QCD_TEMP}
    done

    # Unset IFS
    unset IFS

    # Display Prompt
    command cat ${QCD_TEMP}

    # Terminate Program
    return ${OK}
  fi

  # Continue Program
  return ${CONT}
}

function _parse_standalone_flags() {
  # Store Argument Flag
  local flag="${@:$#}"

  # Check For Standalone Flags
  if [[ "${flag/--help/${HELP}}" == "${HELP}" ]]
  then
    # Print Help
    command cat ${QCD_HELP}

    # Terminate Program
    return ${OK}
  elif [[ "${flag/--version/${VERSION}}" == "${VERSION}" ]]
  then
    # Print Version
    command cat ${QCD_HELP} | command head -n1

    # Terminate Program
    return ${OK}
  elif [[ "${flag/--update/${UPDATE}}" == "${UPDATE}" ]]
  then
    # Prompt User For Confirmation
    command read -p "qcd: Confirm update [y/n]: " confirm

    # Determine Action
    if [[ "${confirm//Y/${YES}}" == "${YES}" ]]
    then
      # Verify Curl Dependency
      command curl &> /dev/null

      # Check Return Value
      if [[ ${?} -eq ${NFD} ]]
      then
        # Display Prompt
        command echo -e "→ Curl dependency not installed"

        # Terminate Program
        return ${NFD}
      fi

      # Display Prompt
      command echo -en "→ Downloading update "

      # Determine Release URL
      release_url=$(command curl --connect-timeout ${TOUT} -s -L ${QCD_RELEASES} | command egrep -s -o "https.*zipball.*" 2> /dev/null)

      # Error Check Release URL
      if [[ ${?} -ne ${OK} || -z ${release_url} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to resolve download link for update"

        # Terminate Program
        return ${ERR}
      fi

      # Download Release Contents
      command curl --connect-timeout ${TOUT} -s -L "${release_url/\",/}" > ${QCD_UPDATE}

      # Error Check Release Contents
      if [[ ${?} -ne ${OK} || ! -f ${QCD_UPDATE} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to download update"

        # Terminate Program
        return ${ERR}
      fi

      # Display Prompt
      command echo -en "\r→ Installing updates "

      # Extract And Install Program Files
      command unzip -o -j ${QCD_UPDATE} -d ${QCD_FOLD} &> /dev/null

      # Error Check Installation
      if [[ ${?} -ne ${OK} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to install update"

        # Terminate Program
        return ${ERR}
      fi

      # Cleanup Installation
      command rm ${QCD_UPDATE} 2> /dev/null
      command rm ${QCD_FOLD}/install_qcd 2> /dev/null

      # Update Bash Environment
      command source ${QCD_FOLD}/qcd.sh 2> /dev/null

      # Get Release Version
      release_version=$(command cat ${QCD_HELP} | command head -n1 | command awk '{print $4}')

      # Display Prompt
      command echo -e "\r→ Update complete    \n\nUpdated to ${release_version}"
    else
      # Display Prompt
      command echo -e "→ Update aborted"
    fi

    # Terminate Program
    return ${OK}
  fi

  # Continue Program
  return ${CONT}
}

# End Argument Parser Functions--------------------------------------------------------------------------------------------------------------------------------------

# TODO: CLEAN UP THIS SHIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

function qcd() {
  # Verify File Integrity
  _verify_files

  # End Resource Validation------------------------------------------------------------------------------------------------------------------------------------------

  # Parse Arguments For Option Flags
  _parse_option_flags ${@}

  # Store Function Status
  local status=${?}

  # Check Function Status
  if [[ ${status} -ne ${CONT} ]]
  then
    return ${status}
  fi

  # Parse Arguments For Standalone Flags
  _parse_standalone_flags ${@}

  # Store Function Status
  local status=${?}

  # Check Function Status
  if [[ ${status} -ne ${CONT} ]]
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

      # Override Command Line Arguments
      dir_arg="${back_dir// /${HWD}}"
    else
      # Format Escaped Characters
      dir_arg=$(_escape_dir "${dir_arg}")
    fi
  fi

  # End Input Formatting---------------------------------------------------------------------------------------------------------------------------------------------

  # Determine If Directory Is Linked
  if [[ -d "${dir_arg}" ]]
  then
    # Change To Valid Directory
    command cd "${dir_arg}"

    # Add Current Directory
    (_add_directory &)

    # Terminate Program
    return ${OK}
  else
    # Define Directory Components
    local dlink=${ESTR} sdir=${ESTR}

    # Define Default Suffix Length
    local suf_len=${#dir_arg}

    # Store Linked Subdirectory
    if [[ "${dir_arg}" == */* ]]
    then
      # Store Subdirectory Suffix
      sdir=${dir_arg#*/}

      # Store Suffix Length
      suf_len=$((${#dir_arg} - ${#sdir} - 1))
    fi

    # Escape Regex Characters
    dlink=$(_escape_regex "${dir_arg:0:${suf_len}}")

    # End Input Directory Parsing------------------------------------------------------------------------------------------------------------------------------------

    # Define Linkage Parameters
    local pathv=${NSET}

    # Check For Indirect Link Matching
    if [[ -z $(command egrep -s -x "^${dlink}$" ${QCD_LINKS} 2> /dev/null) ]]
    then
      # Initialize Parameters
      local i=0 wlink=${ESTR}

      # Check For Hidden Directory Prefix
      if [[ "${dir_arg}" == \.* ]]
      then
        # Override Parameters
        i=2; wlink="${BSLH}${CWD}"
      fi

      # Wildcard Symbolic Link
      for ((; i < ${#dlink}; i++))
      do
        # Get Character At Index
        local c=${dlink:${i}:1}

        # Append Wildcard
        wlink="${wlink}${c}.*"
      done

      # Set IFS
      local IFS=$'\n'

      # Get Sequence Matched Symbolic Paths From Store File
      pathv=($(command printf "%s\n" $(command egrep -i -s -x "${wlink}:.*" ${QCD_STORE} 2> /dev/null)))
    else
      # Set IFS
      local IFS=$'\n'

      # Get Link Matched Symbolic Paths From Store File
      pathv=($(command printf "%s\n" $(command egrep -s -x "${dlink}:.*" ${QCD_STORE} 2> /dev/null)))
    fi

    # Initialize Path Count
    local pathc=${#pathv[@]}

    # End Linkage Acquisition----------------------------------------------------------------------------------------------------------------------------------------

    # Check Result Count
    if [[ ${pathc} -gt 1 ]]
    then
      # Define Matched Path
      local mpath=${ESTR}

      # Store Current Directory
      local pwd=$(_get_pwd)

      # Initialize Filtered Paths
      local fpaths=()

      # Iterate Over Matched Paths
      for path in ${pathv[@]}
      do
        # Substring Path From Delimiter
        path=$(_split_path "${path}")

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

      # List Matching Paths
      if [[ -z ${mpath} ]]
      then
        # Error Check Path Results
        if [[ -z ${fpaths} ]]
        then
          # Terminate Program
          return ${OK}
        fi

        # Display Prompt
        command echo -en "\rqcd: Generating option list..."

        # Generate Prompt
        command echo -e "\rqcd: Multiple paths linked to ${B}${dir_arg%/}${N}" > ${QCD_TEMP}

        # Generate Path Options
        local cnt=1
        for path in ${fpaths[@]}
        do
          # Format Path
          path=$(_format_dir "${path}")

          # Output Path As Option
          command printf "(${cnt}) ${path%/}\n" >> ${QCD_TEMP}

          # Increment Counter
          cnt=$((${cnt} + 1))
        done

        # Display Prompt
        command cat ${QCD_TEMP}

        # End Option View--------------------------------------------------------------------------------------------------------------------------------------------

        # Read User Input
        command read -p "Endpoint: " ept

        # Error Check Input Format
        if [[ -z ${ept} || ! ${ept} =~ ^[0-9]+$ ]]
        then
          # Terminate Program
          return ${ERR}
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
    else
      # Substring Path From Delimiter
      pathv=$(_split_path "${pathv}")
    fi

    # End Path Resolution--------------------------------------------------------------------------------------------------------------------------------------------

    # Error Check Result
    if [[ -z ${pathv} ]]
    then
      # Display Error
      command echo -e "qcd: Cannot resolve linkage to directory"

      # Terminate Program
      return ${ERR}
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
      return ${ERR}
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
      return ${OK}
    fi
  fi

  # End Path Navigation----------------------------------------------------------------------------------------------------------------------------------------------
}

# End QCD Function---------------------------------------------------------------------------------------------------------------------------------------------------

# TODO: CLEAN UP THIS SHIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

function _qcd_comp() {
  # Verify File Integrity
  _verify_files

  # Initialize Completion List
  local comp_list=()

  # Store Command Line Argument
  local curr_arg=${COMP_WORDS[COMP_CWORD]}

  # Determine Completion Type
  if [[ "${curr_arg}" == */* ]]
  then
    # Obtain Symbolic Link
    local link_arg=$(command echo -e "${curr_arg}" | command cut -d '/' -f1)

    # Obtain Trailing Subdirectory Path
    local trail_arg=$(command echo -e "${curr_arg}" | command awk -F '/' '{print $NF}')

    # Obtain Leading Subdirectory Path
    local subs_len=$(command echo -e "${curr_arg}" | command awk -F '/' '{print length($0)-length($NF)}')
    local subs_arg=${curr_arg:$((${#link_arg} + 1)):$((${subs_len} - ${#link_arg} - 1))}

    # End Input Parsing----------------------------------------------------------------------------------------------------------------------------------------------

    # Resolve Linked Directories
    if [[ ! -d "${curr_arg}" ]]
    then
      # Initialize Link Paths
      local link_paths=${NSET}

      # Check For Indirect Link Matching
      if [[ -z $(command egrep -s -x "^${link_arg}$" ${QCD_LINKS} 2> /dev/null) ]]
      then
        # Initialize Parameters
        local i=0 wlink_arg=${ESTR}

        # Check For Hidden Directory Prefix
        if [[ "${link_arg}" == \.* ]]
        then
          # Override Parameters
          i=1; wlink_arg="${BSLH}${CWD}"
        fi

        # Wildcard Symbolic Link
        for ((;i < ${#link_arg}; i++))
        do
          # Get Character At Index
          local c=${link_arg:${i}:1}

          # Append Wildcard
          wlink_arg="${wlink_arg}${c}.*"
        done

        # Set IFS
        local IFS=$'\n'

        # Get Sequence Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -i -x "${wlink_arg}:.*" ${QCD_STORE} 2> /dev/null | command awk -F ':' '{print $2}')))
      else
        # Set IFS
        local IFS=$'\n'

        # Get Link Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -x "${link_arg}:.*" ${QCD_STORE} 2> /dev/null | command awk -F ':' '{print $2}')))
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
        if [[ ! "${trail_arg:0:1}" == "${CWD}" ]]
        then
          # Add Compressed Visible Linked Subdirectories
          sub_dirs+=($(command printf "%s\n" $(command ls -F "${res_dir}" 2> /dev/null | command egrep -s -x ".*/" 2> /dev/null)))
        else
          # Add Compressed Linked Subdirectories
          sub_dirs+=($(command printf "%s\n" $(command ls -aF "${res_dir}" 2> /dev/null | command egrep -s -x ".*/" 2> /dev/null)))
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
        link_sub=$(_escape_dir "${link_arg}${subs_arg}${sub_dir%/}")

        # Determine Subdirectory Existence
        if [[ ! -d "${link_sub}" ]]
        then
          # Append Completion Slash
          link_sub="${link_sub}/"
        fi

        # Append To Linked Subdirectory
        comp_list+=("${link_sub}")
      done

      # Set Completion List
      COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${comp_list[@]}")" "${curr_arg}" 2> /dev/null))

      # End Option Generation----------------------------------------------------------------------------------------------------------------------------------------
    fi
  else
    # Get Symbolic Links From Link File
    local link_dirs=$(command awk '{print $0 "/\n"}' ${QCD_LINKS})

    # Store Current Directory
    local pwd=$(command basename "$(_get_pwd)")

    # Initialize Ignore Boolean
    local curr_rem=${FALSE}

    # End Linkage Acquisition----------------------------------------------------------------------------------------------------------------------------------------

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Symbolic Links
    for link_dir in ${link_dirs}
    do
      # Add Symbolic Links Outside Of Current Directory
      if [[ ! -d "${link_dir}" ]]
      then
        # Ignore Linkages
        if [[ ${curr_rem} -eq ${FALSE} && "${link_dir%/}" == "${pwd%/}" ]]
        then
          # Exlude Current Directory
          curr_rem=$TRUE
        elif [[ "${curr_arg:0:1}" == "${CWD}" && "${link_dir:0:1}" == "${CWD}" || ! "${curr_arg:0:1}" == "${CWD}" && ! "${link_dir:0:1}" == "${CWD}" ]]
        then
          # Add Symbolic Links Of Similar Visibility
          comp_list+=("${link_dir}")
        fi
      fi
    done

    # Set Completion List
    COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${comp_list[@]}")" "${curr_arg}" 2> /dev/null))

    # End Option Generation------------------------------------------------------------------------------------------------------------------------------------------
  fi
}

# End QCD Completion Function----------------------------------------------------------------------------------------------------------------------------------------

function _qcd_init() {
  # Check For Store File
  if [[ -f ${QCD_STORE} ]]
  then
    # Prepare Resource Files
    (qcd --clean && _update_links &)
  fi

  # Cleanup Resource Files On Exit
  command trap _cleanup_files EXIT &> /dev/null

  # Set Environment To Show Visible Files
  command bind 'set match-hidden-files off' &> /dev/null

  # Initialize Completion Engine
  command complete -o nospace -o filenames -A directory -F _qcd_comp qcd
}

# Initialize QCD
_qcd_init

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
