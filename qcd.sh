# Developed by Nalin Ahuja, nalinahuja22

# TODO, multi link forget support (no file overwrite error, README, help)
# TODO, multi path remember support (no file overwrite error, README, help)
# TODO, directory track toggle flag (README, help)
# TODO, ignore current directory with -i flag (README, help)
# TODO, complete flags

# TODO, update README with sid suggestions
# TODO, speed up completion engine
# TODO, speed up qcd routine
# TODO, refactor code
# TODO, convert for i loops to for in loops
# TODO, remove link file (experiment)
# TODO, installer script custom path prompt
# TODO, convert printfs to echos where possible

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Return Values
OK=0
ERR=1
CONT=2
NFD=127
NSEL=255

# Boolean Values
TRUE=1
FALSE=0

# Keycode Values
UP=0
DN=1
EXT=3
ENT=4

# Embedded Values
NSET=0
MINPAD=4
COLNUM=256
TIMEOUT=10

# End Defined Numerical Constants------------------------------------------------------------------------------------------------------------------------------------

# Path Strings
CWD="."
HWD="../"

# Option Flags
LIST="-l"
CLEAN="-c"
TRACK="-t"
IGNORE="-i"
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
QUIT="q"
BSLH="\\"

# Key Escape String
KESC=$(command printf "\033")

# Text Formatting Strings
B=$(command printf "${KESC}[1m")
N=$(command printf "${KESC}(B${KESC}[m")
W=$(command printf "${KESC}[30m${KESC}[47m")

# End Defined String Constants---------------------------------------------------------------------------------------------------------------------------------------

# Program Path
QCD_FOLD=~/.qcd

# Program Files
QCD_PROGRAM=${QCD_FOLD}/qcd.sh
QCD_UPDATE=${QCD_FOLD}/update
QCD_HELP=${QCD_FOLD}/help
QCD_TEMP=${QCD_FOLD}/temp

# Resource Files
QCD_STORE=${QCD_FOLD}/store
QCD_LINKS=${QCD_FOLD}/links
QCD_TRACK=${QCD_FOLD}/.track

# Release URL
QCD_RELEASES="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End Defined Program Constants--------------------------------------------------------------------------------------------------------------------------------------

# Selection Exit Flag
EXIT_FLAG=${FALSE}

# End Global Program Variables---------------------------------------------------------------------------------------------------------------------------------------

function _get_pwd() {
  # Return Present Working Directory
  command echo -e "$(command pwd)/"
}

function _get_path() {
  # Return Real Path
  command echo -e "$(command realpath "${@}")/"
}

function _split_path() {
  # Return Absolute Path Of Linkage
  command echo -e "${@#*:}"
}

function _format_path() {
  # Check For Environment Variable
  if [[ ! -z ${HOME} ]]
  then
    # Return Formatted Path
    command echo -e ${@/${HOME}/\~}
  else
    # Return Original Path
    command echo -e ${@}
  fi
}

function _escape_path() {
  # Store Argument Path
  local fpath="${@}"

  # Escape Space Characters
  fpath="${fpath//\\ / }"
  fpath="${fpath//\\/}"

  # Return Escaped Path
  command echo -e "${fpath}"
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

function _show_cursor() {
  # Enable Keyboard Output
  command stty echo 2> /dev/null

  # Set Cursor To Visible
  command tput cnorm 2> /dev/null
}

function _hide_cursor() {
  # Disable Keyboard Output
  command stty -echo 2> /dev/null

  # Set Cursor To Hidden
  command tput civis 2> /dev/null
}

function _exit_process() {
  # Set Exit Flag To True
  EXIT_FLAG=${TRUE}
}

# End Environment Functions------------------------------------------------------------------------------------------------------------------------------------------

function _read_input() {
  # Initialize Key String
  local key=${ESTR}

  # Initialize Input String
  local c=${ESTR}

  # Read Input Stream
  while [[ 1 ]]
  do
    # Read Character From STDIN
    command read -s -n1 c 2> /dev/null

    # Check Break Conditions
    if [[ -z ${c} || ${c} == ${QUIT} ]]
    then
      # Return Exit Key Action
      if [[ -z ${c} ]]; then command echo -e "${ENT}"; fi
      if [[ ${c} == ${QUIT} ]]; then command echo -e "${EXT}"; fi

      # Break Loop
      break
    fi

    # Append Character To Key String
    key="${key}${c}"

    # Check Break Conditions
    if [[ ${#key} -eq 3 ]]
    then
      # Return Arrow Key Action
      if [[ ${key} == "${KESC}[A" ]]; then command echo -e "${UP}"; fi
      if [[ ${key} == "${KESC}[B" ]]; then command echo -e "${DN}"; fi

      # Break Loop
      break
    fi
  done
}

function _clear_menu() {
  # Clear Menu Option Entries
  for ((oi=0; oi <= ${1} + 1; oi++))
  do
    # Go To Beginning Of Line
    command printf "${KESC}[${COLNUM}D"

    # Clear Line
    command printf "${KESC}[K"

    # Go Up One Line
    command printf "${KESC}[1A"
  done

  # Go Down One Line
  command printf "${KESC}[1B"
}

function _display_menu() {
  # Prepare Terminal Environment
  _hide_cursor

  # Initialize Selected Line
  local sel_line=${NSET}

  # Begin Selection Loop
  while [[ 1 ]]
  do
    # Initialize Option Index
    local oi=${NSET}

    # Clear Temp File
    command echo -en > ${QCD_TEMP}

    # Iterate Over Options
    for opt in "${@}"
    do
      # Format Option
      opt=$(_format_path "${opt%/}")

      # Print Conditionally Formatted Option
      if [[ ${oi} -eq ${sel_line} ]]
      then
        command echo -e "${W} ${opt} ${N}" >> ${QCD_TEMP}
      else
        command echo -e " ${opt} " >> ${QCD_TEMP}
      fi

      # Increment Option Index
      oi=$((${oi} + 1))
    done

    # Output Menu
    command cat ${QCD_TEMP}

    # Read User Input
    local key=$(_read_input)

    # Check Exit Flag
    if [[ ${EXIT_FLAG} -eq ${TRUE} ]]
    then
      # Restore Exit Flag
      EXIT_FLAG=${FALSE}

      # Set Selected Line
      sel_line=${NSEL}

      # Break Loop
      break
    fi

    # Update Cursor Position
    if [[ ${key} -eq ${UP} ]]
    then
      # Decrement Selected Line
      sel_line=$((${sel_line} - 1))
    elif [[ ${key} -eq ${DN} ]]
    then
      # Increment Selected Line
      sel_line=$((${sel_line} + 1))
    elif [[ ${key} -eq ${ENT} || ${key} -eq ${EXT} ]]
    then
      # Reset Selected Line
      if [[ ${key} -eq ${EXT} ]]; then sel_line=${NSEL}; fi

      # Break Loop
      break
    fi

    # Check For Option Loopback
    if [[ ${sel_line} -eq $# ]]
    then
      # Jump To Beginning
      sel_line=0
    elif [[ ${sel_line} -lt 0 ]]
    then
      # Jump To End
      sel_line=$(($# - 1))
    fi

    # Clear Previous Menu
    _clear_menu $(($# - 1))
  done

  # Restore Terminal Environment
  _clear_menu $# && _show_cursor

  # Return Selected Line
  return ${sel_line}
}

# End Menu Selection Functions--------------------------------------------------------------------------------------------------------------------------------------------

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
    command touch ${QCD_STORE} 2> /dev/null
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
  local adir=$(_get_pwd)

  # Check For Argument Path
  if [[ $# -gt 0 ]]
  then
    # Store Argument Path
    adir=$(_get_path "${@}")

    # Check Path Validity
    if [[ ! -d "${adir}" ]]
    then
      # Return To Caller
      return ${ERR}
    fi
  fi

  # Store Directory If Unique
  if [[ ! "${adir%/}" == "${HOME%/}" && -z $(command egrep -s -x ".*:${adir}" ${QCD_STORE} 2> /dev/null) ]]
  then
    # Store Basename Of Path
    local ept=$(command basename "${adir}")

    # Append Data To Store File
    command echo -e "${ept}:${adir}" >> ${QCD_STORE}

    # Sort Store File In Place
    command sort -o ${QCD_STORE} -n -t ':' -k2 ${QCD_STORE}

    # Update Link File
    _update_links
  fi

  # Return To Caller
  return ${OK}
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

  # Return To Caller
  return ${OK}
}

function _remove_symbolic_link() {
  # Store Argument Link
  local rlink=$(_escape_regex "${@%/}")

  # Remove Link From Store File
  command egrep -s -v -x "${rlink}:.*" ${QCD_STORE} > ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}

  # Return To Caller
  return ${OK}
}

# End Link Management Functions--------------------------------------------------------------------------------------------------------------------------------------

function _parse_option_flags() {
  # Store Argument Flag
  local flag="${@:$#}"

  # Check For Option Flags
  if [[ ${flag/--remember/${REMEMBER}} == ${REMEMBER} ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Add Current Directory
      (_add_directory &)
    else
      # TODO, multi path remember

      # Store Path Argument
      local lpath="${@:1:$(($# - 1))}"

      # Add Indicated Path
      (_add_directory "${lpath}" &)
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--forget/${FORGET}} == ${FORGET} ]]
  then
    # Determine Removal Type
    if [[ $# -eq 1 ]]
    then
      # Remove Current Directory
      (_remove_directory &)
    else
      # TODO, multi link forget

      # Store Link Argument
      local ldir="${@:1:$(($# - 1))}"

      # Remove Symbolic Link
      (_remove_symbolic_link "${ldir}" &)
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--clean/${CLEAN}} == ${CLEAN} ]]
  then
    # Store Linked Paths From Store File
    local lpaths=$(command awk -F ':' '{print $2}' ${QCD_STORE})

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linked Paths
    for lpath in ${lpaths}
    do
      # Remove Invalid Paths
      if [[ ! -d "${lpath}" ]]
      then
        _remove_directory "${lpath}"
      fi
    done

    # Unset IFS
    unset IFS

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--mkdir/${MKDIRENT}} == ${MKDIRENT} ]]
  then
    # Verify Argument Count
    if [[ $# -lt 2 ]]
    then
      # Display Prompt
      command echo -e "qcd: Insufficient arguments"

      # Terminate Program
      return ${ERR}
    else
      # Store Path Argument
      local real_path="${@:1:$(($# - 1))}"

      # Store Trailing Path
      local trail_path=$(command basename "${real_path}")

      # Store Prefix Path
      local prefix_path="${real_path:0:$((${#real_path} - ${#trail_path}))}"

      # Verify Path Components
      if [[ -d "${real_path%/}" ]]
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

      # Create Directory At Location
      command mkdir "${real_path}"

      # QCD Into New Directory
      qcd "${real_path}"
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--list/${LIST}} == ${LIST} ]]
  then
    # Display Prompt
    command echo -en "\rqcd: Generating link map..."

    # Load Linkages From Store File
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
      linkages=$(command echo -e "${linkages}" | command egrep -s -x "${sphrase%/}.*:.*" 2> /dev/null)
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
    if [[ ${max_link} -lt ${MINPAD} ]]
    then
      max_link=${MINPAD}
    fi

    # Format Header
    command printf "\r${W} %-${max_link}s  %-$((${cols} - ${max_link} - 3))s${N}\n" "Link" "Directory" > ${QCD_TEMP}

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linkages
    for linkage in ${linkages}
    do
      # Form Linkage Components
      local link=$(command echo -e "${linkage}" | command awk -F ':' '{print $1}')
      local path=$(command echo -e "${linkage}" | command awk -F ':' '{print $2}')

      # Format Linkage
      command printf " %-${max_link}s  %s" "${link}" "$(_format_path "${path%/}")\n" >> ${QCD_TEMP}
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
  if [[ ${flag/--help/${HELP}} == ${HELP} ]]
  then
    # Print Help File
    command cat ${QCD_HELP}

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--version/${VERSION}} == ${VERSION} ]]
  then
    # Print Installed Version
    command cat ${QCD_HELP} | command head -n1

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--update/${UPDATE}} == ${UPDATE} ]]
  then
    # Prompt User For Confirmation
    command read -p "qcd: Confirm update [y/n]: " confirm

    # Determine Action
    if [[ ${confirm//Y/${YES}} == ${YES} ]]
    then
      # Verify Curl Dependency
      command curl &> /dev/null

      # Check Operation Status
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
      local release_url=$(command curl --connect-timeout ${TIMEOUT} -s -L ${QCD_RELEASES} | command egrep -s -o "https.*zipball.*" 2> /dev/null)

      # Error Check Release URL
      if [[ ${?} -ne ${OK} || -z ${release_url} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to resolve download link for update"

        # Terminate Program
        return ${ERR}
      fi

      # Download Release Contents
      command curl --connect-timeout ${TIMEOUT} -s -L "${release_url/\",/}" > ${QCD_UPDATE}

      # Error Check Release Contents
      if [[ ${?} -ne ${OK} || ! -f ${QCD_UPDATE} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to download update"

        # Terminate Program
        return ${ERR}
      fi

      # Display Prompt
      command echo -en "\r→ Installing updates  "

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

      # Display Prompt
      command echo -en "\r→ Configuring updates "

      # Update Bash Environment
      command source ${QCD_PROGRAM} 2> /dev/null

      # Error Check Installation
      if [[ ${?} -ne ${OK} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to configure update "

        # Terminate Program
        return ${ERR}
      fi

      # Define Installer Executable Path
      local QCD_INSTALLER=${QCD_FOLD}/install_qcd

      # Cleanup Installation
      command rm ${QCD_UPDATE} ${QCD_INSTALLER} 2> /dev/null

      # Get Release Version
      local release_version=$(command cat ${QCD_HELP} | command head -n1 | command awk '{print $4}')

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

function qcd() {
  # Verify Resource Files
  _verify_files

  # End Resource Validation------------------------------------------------------------------------------------------------------------------------------------------

  # Parse Arguments For Option Flags
  _parse_option_flags ${@}

  # Store Function Status
  local fstat=${?}

  # Check Function Status
  if [[ ${fstat} -ne ${CONT} ]]
  then
    # Terminate Program
    return ${fstat}
  fi

  # Parse Arguments For Standalone Flags
  _parse_standalone_flags ${@}

  # Store Function Status
  local fstat=${?}

  # Check Function Status
  if [[ ${fstat} -ne ${CONT} ]]
  then
    # Terminate Program
    return ${fstat}
  fi

  # End Argument Parsing---------------------------------------------------------------------------------------------------------------------------------------------

  # Store Directory Argument
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
      local back_dir=$(command echo -e "%${back_height}s")

      # Override Command Line Arguments
      dir_arg="${back_dir// /${HWD}}"
    else
      # Format Escaped Characters
      dir_arg=$(_escape_path "${dir_arg}")
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
    if [[ -z $(command egrep -s -x "${dlink}:.*" ${QCD_STORE} 2> /dev/null) ]]
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
        path=$(_escape_path "${path}${sdir}")

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
        # Set Matched Path
        mpath="${fpaths[@]}"
      fi

      # End Path Filtering-------------------------------------------------------------------------------------------------------------------------------------------

      # List Matching Paths
      if [[ -z ${mpath} && ! -z ${fpaths} ]]
      then
        # Display Prompt
        command echo -e "qcd: Multiple paths linked to ${B}${dir_arg%/}${N}"

        # Generate Menu
        _display_menu ${fpaths[@]}

        # Store Function Status
        local ept=${?}

        # Check Function Status
        if [[ ${ept} -eq ${NSEL} ]]
        then
          return ${OK}
        fi

        # Set To Manually Selected Endpoint
        pathv="${fpaths[${ept}]}"
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
      command echo -e "qcd: $(_format_path "${pathv%/}"): Directory does not exist"

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

function _qcd_comp() {
  # Verify File Integrity
  _verify_files

  # End Resource Validation------------------------------------------------------------------------------------------------------------------------------------------

  # Initialize Completion List
  local comp_list=()

  # Store Command Line Argument
  local curr_arg=${COMP_WORDS[COMP_CWORD]}

  # End Global Function Variable Initialization----------------------------------------------------------------------------------------------------------------------

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
      if [[ -z $(command egrep -s -x "${link_arg}" ${QCD_LINKS} 2> /dev/null) ]]
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
        local res_dir=$(_escape_path "${link_path}${subs_arg}")

        # Add Resolved Directory
        if [[ -d "${res_dir}" ]]
        then
          # Add Resolved Directory To List
          res_dirs+=($(command printf "%s\n" "${res_dir}"))
        fi
      done
    else
      # Resolve Local Directories
      res_dirs=$(_escape_path "${curr_arg}")
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
        if [[ ! ${trail_arg:0:1} == ${CWD} ]]
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
        link_sub=$(_escape_path "${link_arg}${subs_arg}${sub_dir%/}")

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
        elif [[ ${curr_arg:0:1} == ${CWD} && ${link_dir:0:1} == ${CWD} || ! ${curr_arg:0:1} == ${CWD} && ! ${link_dir:0:1} == ${CWD} ]]
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

  # Cleanup Resource Files On EXIT
  command trap _cleanup_files EXIT &> /dev/null

  # Set Exit Global To True On SIGINT
  command trap _exit_process SIGINT &> /dev/null

  # Set Environment To Show Visible Files
  command bind 'set match-hidden-files off' &> /dev/null

  # Initialize Completion Engine
  command complete -o nospace -o filenames -A directory -F _qcd_comp qcd
}

# Initialize QCD
_qcd_init

# End QCD Initialization---------------------------------------------------------------------------------------------------------------------------------------------
