# Developed by Nalin Ahuja, nalinahuja22

# TODO, add -c flag output for confirmation
# TODO, show options flag, don't navigate
# TODO, fix SIGINT bug

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Boolean Values
declare TRUE=1 FALSE=0

# Keycode Values
declare UP=0 DN=1 EXT=2 ENT=3

# Function Return Values
declare OK=0 ERR=1 CONT=2 NFD=127 NSEL=255

# Embedded Values
declare NSET=0 MINPAD=4 TIMEOUT=10 COLNUM=256

# End Defined Numerical Constants------------------------------------------------------------------------------------------------------------------------------------

# Embedded Strings
declare CWD="." HWD="../" YES="y" QUIT="q" ESTR="" FLSH="/" BSLH="\\" KESC=$(command printf "\033")

# Program Flags
declare HELP="-h" LIST="-l" CLEAN="-c" TRACK="-t" UPDATE="-u" VERSION="-v" FORGET="-f" REMEMBER="-r" MKDIRENT="-m"

# Text Formatting Strings
declare B=$(command printf "${KESC}[1m") N=$(command printf "${KESC}(B${KESC}[m") W=$(command printf "${KESC}[30m${KESC}[47m")

# End Defined String Constants---------------------------------------------------------------------------------------------------------------------------------------

# Program Path
declare QCD_FOLD=~/.qcd

# Program Files
declare QCD_PROG=${QCD_FOLD}/qcd.sh
declare QCD_HELP=${QCD_FOLD}/help
declare QCD_TEMP=${QCD_FOLD}/temp

# Resource Files
declare QCD_STORE=${QCD_FOLD}/store
declare QCD_LINKS=${QCD_FOLD}/links
declare QCD_TRACK=${QCD_FOLD}/.track

# Release Files
declare QCD_UPDATE=${QCD_FOLD}/update
declare QCD_INSTALL=${QCD_FOLD}/install_qcd

# Release Link
declare QCD_RELEASES="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End Defined Program Constants--------------------------------------------------------------------------------------------------------------------------------------

# Selection Exit Flag
declare EXIT_FLAG=${FALSE}

# End Global Program Variables---------------------------------------------------------------------------------------------------------------------------------------

function _get_pwd() {
  # Store Current Directory
  local pwd=$(command pwd)

  # Return Current Directory
  command echo -e "${pwd}${FLSH}"
}

function _get_path() {
  # Store Argument Directory
  local dir=$(command realpath "${@}")

  # Return Absolute Path
  command echo -e "${dir}${FLSH}"
}

function _get_rname() {
  # Store Argument Directory
  local dir="${@%/}${FLSH}"

  # Get Prefix String
  local pfx="${dir#*/*}"

  # Determine Return
  if [[ -z ${pfx} ]]
  then
    # Return Full Argument Directory
    command echo -e "${dir%/}"
  else
    # Determine Substring Bounds
    local si=0 ei=$((${#dir} - ${#pfx} - 1))

    # Return Argument Directory Substring
    command echo -e "${dir:${si}:${ei}}"
  fi
}

function _get_dname() {
  # Store Argument Directory
  local dir="${@%/}${FLSH}"

  # Get Prefix String
  local pfx="${dir%/*/}"

  # Get Suffix String
  local sfx="${dir:$((${#pfx} + 1))}"

  # Determine Return
  if [[ -z ${sfx} ]]
  then
    # Return Prefix String
    command echo -e "${pfx%/}"
  else
    # Return Suffix String
    command echo -e "${sfx%/}"
  fi
}

function _split_path() {
  # Return Absolute Path Of Symbolic Link
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
  local path="${@}"

  # Remove Escape Characters
  path="${path//\\/}"

  # Return Escaped Path
  command echo -e "${path}"
}

function _escape_regex() {
  # Store Argument String
  local str="${@}"

  # Escape Regex Characters
  str="${str//\*/\\*}"
  str="${str//\?/\\?}"
  str="${str//\./\\.}"
  str="${str//\$/\\$}"

  # Return Escaped String
  command echo -e "${str}"
}

# End Utility Functions----------------------------------------------------------------------------------------------------------------------------------------------

function _show_output() {
  # Enable Terminal Output
  command stty echo 2> /dev/null

  # Set Cursor To Visible
  command tput cnorm 2> /dev/null
}

function _hide_output() {
  # Disable Terminal Output
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
  # Initialize String Buffers
  local input=${ESTR} c=${ESTR}

  # Read Input Stream
  while [[ 1 ]]
  do
    # Read One Character From STDIN
    command read -s -n1 c 2> /dev/null

    # Check Break Conditions
    if [[ -z ${c} ]]
    then
      # Return Enter Action
      command echo -e "${ENT}" && break
    elif [[ ${c} == ${QUIT} ]]
    then
      # Return Quit Action
      command echo -e "${EXT}" && break
    fi

    # Append Character To Input Buffer
    input="${input}${c}"

    # Check Break Conditions
    if [[ ${#input} == 3 ]]
    then
      # Return Arrow Key Action
      if [[ ${input} == "${KESC}[A" ]]
      then
        # Return Up Arrow Action
        command echo -e "${UP}"
      elif [[ ${input} == "${KESC}[B" ]]
      then
        # Return Down Arrow Action
        command echo -e "${DN}"
      fi

      # Break Loop
      break
    fi
  done
}

function _clear_output() {
  # Clear Line Entries
  for ((li=0; li <= ${1}; li++))
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

function _generate_menu() {
  # Prepare Terminal Environment
  _hide_output

  # Reset Exit Flag
  EXIT_FLAG=${FALSE}

  # Initialize Selected Option
  local sel_opt=${NSET}

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

      # Conditionally Format Option
      if [[ ${oi} == ${sel_opt} ]]
      then
        # Print Option As Seleted
        command echo -e "${W} ${opt} ${N}" >> ${QCD_TEMP}
      else
        # Print Option As Unselected
        command echo -e " ${opt} " >> ${QCD_TEMP}
      fi

      # Increment Option Index
      oi=$((${oi} + 1))
    done

    # Output Selection
    command cat ${QCD_TEMP}

    # Read User Input
    local key=$(_read_input)

    # Check Exit Flag
    if [[ ${EXIT_FLAG} == ${TRUE} ]]
    then
      # Reset Exit Flag
      EXIT_FLAG=${FALSE}

      # Reset Option
      sel_opt=${NSEL}

      # Break Loop
      break
    fi

    # Update Cursor Position
    if [[ ${key} == ${UP} ]]
    then
      # Decrement Selected Line
      sel_opt=$((${sel_opt} - 1))
    elif [[ ${key} == ${DN} ]]
    then
      # Increment Selected Line
      sel_opt=$((${sel_opt} + 1))
    elif [[ ${key} == ${ENT} || ${key} == ${EXT} ]]
    then
      # Check Exit Key
      if [[ ${key} == ${EXT} ]]
      then
        # Reset Option
        sel_opt=${NSEL}
      fi

      # Break Loop
      break
    fi

    # Check For Option Loopback
    if [[ ${sel_opt} == ${#@} ]]
    then
      # Jump To Top
      sel_opt=0
    elif [[ ${sel_opt} == -1 ]]
    then
      # Jump To Bottom
      sel_opt=$((${#@} - 1))
    fi

    # Clear Previous Selection
    _clear_output ${#@}
  done

  # Clear All Outputs
  _clear_output $((${#@} + 1))

  # Restore Terminal Environment
  _show_output

  # Return Selected Option
  return ${sel_opt}
}

# End User Selection Functions---------------------------------------------------------------------------------------------------------------------------------------

function _update_store() {
  # Check Exit Status
  if [[ ${1} == ${OK} ]]
  then
    # Update Store File
    command mv ${QCD_TEMP} ${QCD_STORE} 2> /dev/null
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
}

function _cleanup_files() {
  # Remove Link And Temp Files
  command rm ${QCD_LINKS} ${QCD_TEMP} 2> /dev/null
}

# End File Management Functions--------------------------------------------------------------------------------------------------------------------------------------

function _add_directory() {
  # Get Current Path
  local adir=$(_get_pwd)

  # Check For Argument Path
  if [[ ${#@} != 0 ]]
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
    # Get Directory Name Of Path
    local ept=$(_get_dname "${adir}")

    # Append Data To Store File
    command echo -e "${ept}:${adir}" >> ${QCD_STORE}

    # Sort Store File In Place
    command sort -o ${QCD_STORE} -n -t ':' -k2 ${QCD_STORE}
  fi

  # Return To Caller
  return ${OK}
}

function _remove_directory() {
  # Get Current Path
  local rdir=$(_get_pwd)

  # Check For Argument Path
  if [[ ${#@} != 0 ]]
  then
    # Store Argument Path
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

# End Linkage Management Functions-----------------------------------------------------------------------------------------------------------------------------------

function _parse_option_flags() {
  # Store Argument Flag
  local flag="${@:${#@}}"

  # Check For Option Flags
  if [[ ${flag/--remember/${REMEMBER}} == ${REMEMBER} ]]
  then
    # Determine Remember Type
    if [[ ${#@} == 1 ]]
    then
      # Add Current Directory
      (_add_directory &> /dev/null &)
    else
      # Store Directory Argument
      local dir="${@:1:$((${#@} - 1))}"

      # Add Directory As Linkage
      (_add_directory "${dir}" &> /dev/null &)
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--forget/${FORGET}} == ${FORGET} ]]
  then
    # Determine Forget Type
    if [[ ${#@} == 1 ]]
    then
      # Remove Current Directory
      (_remove_directory &> /dev/null &)
    else
      # Store Link Argument
      local link="${@:1:$((${#@} - 1))}"

      # Remove Symbolic Linkages
      (_remove_symbolic_link "${link}" &> /dev/null &)
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--mkdir/${MKDIRENT}} == ${MKDIRENT} ]]
  then
    # Verify Argument Count
    if [[ ${#@} != 2 ]]
    then
      # Display Prompt
      command echo -e "qcd: Insufficient arguments"

      # Terminate Program
      return ${ERR}
    else
      # Store Directory Path Component
      local dir_path="${@:1:$((${#@} - 1))}"

      # Store Trailing Path Component
      local trail_path=$(_get_dname "${dir_path}")

      # Determine Substring Bounds
      local si=0 ei=$((${#dir_path} - ${#trail_path}))

      # Store Prefix Path Component
      local pfx_path="${dir_path:${si}:${ei}}"

      # Verify Path Components
      if [[ -d "${dir_path%/}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Directory already exists"

        # Terminate Program
        return ${ERR}
      elif [[ ! -z ${pfx_path} && ! -d "${pfx_path%/}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Invalid path to new directory"

        # Terminate Program
        return ${ERR}
      fi

      # Create Directory At Location
      command mkdir "${dir_path}"

      # QCD Into New Directory
      qcd "${dir_path}"
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--list/${LIST}} == ${LIST} ]]
  then
    # Display Prompt
    command echo -en "\rqcd: Generating link map..."

    # Initialize Symbolic Links
    local sym_links=${NSET}

    # Conditionally Fetch Symbolic Links
    if [[ ${#@} == 1 ]]
    then
      # Get All Symbolic Links From Store File
      sym_links=$(qcd --clean && command cat ${QCD_STORE})
    else
      # Store Regex Argument
      local regex="${@:1:$((${#@} - 1))}"

      # Expand Regex Characters
      regex="${regex//\*/\.\*}"
      regex="${regex//\?/\.}"
      regex="${regex%/}"

      # Get All Symbolic Links From Store File By Regex
      sym_links=$(qcd --clean && command egrep -s -x "${regex}.*:.*" ${QCD_STORE} 2> /dev/null)
    fi

    # Error Check Symbolic Links
    if [[ -z ${sym_links} ]]
    then
      # Display Prompt
      command echo -e "\rqcd: No linkages found      "

      # Terminate Program
      return ${ERR}
    fi

    # Store Terminal Column Count
    local tcols=$(command tput cols)

    # Determine Column Padding
    local pcols=$(command echo -e "${sym_links}" | command awk -F ':' '{print $1}' | command awk '{print length}' | command sort -n | command tail -n1)

    # Error Check Column Padding
    if [[ ${pcols} -lt ${MINPAD} ]]
    then
      # Set Padding To Minimum
      pcols=${MINPAD}
    fi

    # Format Header
    command printf "\r${W} %-${pcols}s  %-$((${tcols} - ${pcols} - 3))s${N}\n" "Link" "Directory" > ${QCD_TEMP}

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linkages
    for sym_link in ${sym_links}
    do
      # Form Linkage Components
      local path=$(_split_path "${sym_link}")
      local link=$(_get_dname "${path}")

      # Format Linkage
      command printf " %-${pcols}s  %s\n" "${link}" "$(_format_path "${path%/}")" >> ${QCD_TEMP}
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
  local flag="${@:${#@}}"

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
  elif [[ ${flag/--clean/${CLEAN}} == ${CLEAN} ]]
  then
    # Get Linked Paths From Store File
    local lpaths=$(command awk -F ':' '{print $2}' ${QCD_STORE})

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Linked Paths
    for lpath in ${lpaths}
    do
      # Check Path Validity
      if [[ ! -d "${lpath}" ]]
      then
        # Remove Invalid Path
        (_remove_directory "${lpath}" &> /dev/null)
      fi
    done

    # Unset IFS
    unset IFS

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--track-dirs/${TRACK}} == ${TRACK} ]]
  then
    # Check For Tracking File
    if [[ -f ${QCD_TRACK} ]]
    then
      # Display Prompt
      command echo -e "qcd: Directory tracking ${B}enabled${N}"

      # Prompt User For Confirmation
      command read -p "→ Disable tracking [y/n]: " confirm
    else
      # Display Prompt
      command echo -e "qcd: Directory tracking ${B}disabled${N}"

      # Prompt User For Confirmation
      command read -p "→ Enable tracking [y/n]: " confirm
    fi

    # Clear All Outputs
    _clear_output 2

    # Determine Action
    if [[ ${confirm//Y/${YES}} == ${YES} ]]
    then
      # Check For Tracking File
      if [[ ! -f ${QCD_TRACK} ]]
      then
        # Create Tracking File
        command touch ${QCD_TRACK}

        # Display Prompt
        command echo -e "qcd: Directory tracking ${B}enabled${N}"
      else
        # Remove Tracking File
        command rm ${QCD_TRACK}

        # Display Prompt
        command echo -e "qcd: Directory tracking ${B}disabled${N}"
      fi
    fi

    # Terminate Program
    return ${OK}
  elif [[ ${flag/--update/${UPDATE}} == ${UPDATE} ]]
  then
    # Display Prompt
    command echo -e "qcd: Currently running $(command cat ${QCD_HELP} | command head -n1 | command awk '{print $4}')"

    # Prompt User For Confirmation
    command read -p "→ Confirm update [y/n]: " confirm

    # Determine Action
    if [[ ${confirm//Y/${YES}} == ${YES} ]]
    then
      # Clear Confirmation Prompt
      _clear_output 1

      # Verify Curl Dependency
      command curl &> /dev/null

      # Check Operation Status
      if [[ ${?} == ${NFD} ]]
      then
        # Display Prompt
        command echo -e "→ Curl dependency not installed"

        # Terminate Program
        return ${NFD}
      fi

      # Display Prompt
      command echo -en "→ Downloading update "

      # Determine Release URL
      local release_url=$(command curl --connect-timeout ${TIMEOUT} -sL ${QCD_RELEASES} 2> /dev/null | command egrep -s -o "https.*zipball.*" 2> /dev/null)

      # Error Check Release URL
      if [[ ${?} != ${OK} || -z ${release_url} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to resolve download link for update"

        # Terminate Program
        return ${ERR}
      fi

      # Download Release Contents
      command curl --connect-timeout ${TIMEOUT} -sL "${release_url/\",/}" > ${QCD_UPDATE}

      # Error Check Release Contents
      if [[ ${?} != ${OK} || ! -f ${QCD_UPDATE} ]]
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
      if [[ ${?} != ${OK} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to install update"

        # Terminate Program
        return ${ERR}
      fi

      # Display Prompt
      command echo -en "\r→ Configuring updates "

      # Update Bash Environment
      command source ${QCD_PROG} 2> /dev/null

      # Error Check Installation
      if [[ ${?} != ${OK} ]]
      then
        # Display Prompt
        command echo -e "\r→ Failed to configure update "

        # Terminate Program
        return ${ERR}
      fi

      # Cleanup Installation
      command rm ${QCD_UPDATE} ${QCD_INSTALL} 2> /dev/null

      # Display Prompt
      command echo -e "\r→ Update complete     "

      # Clear All Outputs
      _clear_output 2

      # Display Prompt
      command echo -e "qcd: Updated to $(command cat ${QCD_HELP} | command head -n1 | command awk '{print $4}')"
    else
      # Clear All Outputs
      _clear_output 2
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
  local fstatus=${?}

  # Check Function Status
  if [[ ${fstatus} != ${CONT} ]]
  then
    # Terminate Program
    return ${fstatus}
  fi

  # Parse Arguments For Standalone Flags
  _parse_standalone_flags ${@}

  # Store Function Status
  local fstatus=${?}

  # Check Function Status
  if [[ ${fstatus} != ${CONT} ]]
  then
    # Terminate Program
    return ${fstatus}
  fi

  # End Argument Parsing---------------------------------------------------------------------------------------------------------------------------------------------

  # Initialize Argument Components
  local dir_arg=${ESTR}

  # Check Argument Validity
  if [[ -z ${@} ]]
  then
    # Set To Home Directory
    dir_arg=~
  else
    # Initialize Directory Argument
    dir_arg="${@}"

    # Check For Back Directory Pattern
    if [[ "${dir_arg}" =~ ^[0-9]+\.\.$ ]]
    then
      # Determine Back Directory Height
      local back_height=${dir_arg:0:$((${#dir_arg} - 2))}

      # Generate Expanded Back Directory
      local back_dir=$(command printf "%${back_height}s")

      # Override Directory Arguments
      dir_arg="${back_dir// /${HWD}}"

      # Override Option Argument
      opt_arg=${ESTR}
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

    # Check For Tracking File
    if [[ -f ${QCD_TRACK} ]]
    then
      # Add Current Directory
      (_add_directory &> /dev/null &)
    fi

    # Terminate Program
    return ${OK}
  else
    # Initialize Directory Components
    local sym_link=${ESTR} sub_link=${ESTR}

    # Initialize Prefix Length
    local pfx_len=${#dir_arg}

    # Determine Linked Subdirectory
    if [[ "${dir_arg}" == */* ]]
    then
      # Extract Linked Subdirectory
      sub_link=${dir_arg#*/}

      # Update Prefix Length
      pfx_len=$((${pfx_len} - ${#sub_link} - 1))
    fi

    # Extract Symbolic Link
    sym_link=$(_escape_regex "${dir_arg:0:${pfx_len}}")

    # End Input Directory Parsing------------------------------------------------------------------------------------------------------------------------------------

    # Initialize Linkage Parameters
    local pathv=${NSET}

    # Check For Indirect Link Matching
    if [[ -z $(command egrep -s -x "${sym_link}:.*" ${QCD_STORE} 2> /dev/null) ]]
    then
      # Initialize Parameters
      local i=0 wld_link=${ESTR}

      # Check For Hidden Directory Prefix
      if [[ "${dir_arg}" == \.* ]]
      then
        # Override Parameters
        i=2; wld_link="${BSLH}${CWD}"
      fi

      # Wildcard Symbolic Link
      for ((; i < ${#sym_link}; i++))
      do
        # Get Character At Index
        local c=${sym_link:${i}:1}

        # Append Wildcard
        wld_link="${wld_link}${c}.*"
      done

      # Set IFS
      local IFS=$'\n'

      # Get Sequence Matched Symbolic Paths From Store File
      pathv=($(command printf "%s\n" $(command egrep -i -s -x "${wld_link}:.*" ${QCD_STORE} 2> /dev/null)))
    else
      # Set IFS
      local IFS=$'\n'

      # Get Link Matched Symbolic Paths From Store File
      pathv=($(command printf "%s\n" $(command egrep -s -x "${sym_link}:.*" ${QCD_STORE} 2> /dev/null)))
    fi

    # Initialize Path Count
    local pathc=${#pathv[@]}

    # End Linkage Acquisition----------------------------------------------------------------------------------------------------------------------------------------

    # Check Result Count
    if [[ ${pathc} -gt 1 ]]
    then
      # Initialize Matched Path
      local mpath=${ESTR}

      # Store Current Directory
      local pwd=$(_get_pwd)

      # Initialize Filtered Paths
      local fpaths=()

      # Iterate Over Path Values
      for path in ${pathv[@]}
      do
        # Substring Path From Delimiter
        path=$(_split_path "${path}")

        # Form Complete Path
        path=$(_escape_path "${path}${sub_link}")

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
      if [[ ${pathc} == 1 ]]
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

        # Generate Selection Menu
        _generate_menu ${fpaths[@]}

        # Store Function Status
        local ept=${?}

        # Check Function Status
        if [[ ${ept} == ${NSEL} ]]
        then
          # Terminate Program
          return ${OK}
        fi

        # Set To Manually Selected Endpoint
        pathv="${fpaths[${ept}]}"
      else
        # Set To Automatically Selected Endpoint
        pathv="${mpath}"
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
      if [[ ${pathc} != 1 ]]
      then
        # Print Separator
        command echo
      fi

      # Display Error
      command echo -e "qcd: $(_format_path "${pathv%/}"): Directory does not exist"

      # Remove Current Directory
      (_remove_directory "${pathv}" &> /dev/null &)

      # Terminate Program
      return ${ERR}
    else
      # Switch To Linked Path
      command cd "${pathv}"

      # Validate Linked Subdirectory
      if [[ ! -z ${sub_link} ]]
      then
        # Extract Trailing Path Component
        local trail_comp="${sub_link##*/}"

        # Determine Leading Path Locality
        local si=0 ei=$((${#sub_link} - ${#trail_comp}))

        # Extract Leading Path Component
        local lead_comp=${sub_link:${si}:${ei}}

        # Validate Leading Path Component
        if [[ -z ${lead_comp} ]]
        then
          # Update Path Components
          lead_comp=${trail_comp}; trail_comp=${ESTR}
        fi

        # Validate Leading Path Existence
        if [[ ! -z ${lead_comp} && -d "${lead_comp}" ]]
        then
          # Switch To Leading Path
          command cd "${lead_comp}"

          # Validate Trailing Path Existence
          if [[ ! -z ${trail_comp} && -d "${trail_comp}" ]]
          then
            # Switch To Trailing Path
            command cd "${trail_comp}"
          fi
        fi

        # Check For Tracking File
        if [[ -f ${QCD_TRACK} ]]
        then
          # Add Current Directory
          (_add_directory &> /dev/null &)
        fi
      fi

      # Terminate Program
      return ${OK}
    fi
  fi

  # End Path Navigation----------------------------------------------------------------------------------------------------------------------------------------------
}

# End QCD Function---------------------------------------------------------------------------------------------------------------------------------------------------

function _qcd_comp() {
  # Verify Resource Files
  _verify_files

  # End Resource Validation------------------------------------------------------------------------------------------------------------------------------------------

  # Initialize Completion List
  local comp_list=()

  # Store Current Argument
  local curr_arg=${COMP_WORDS[COMP_CWORD]}

  # End Completion Resource Initialization---------------------------------------------------------------------------------------------------------------------------

  # Determine Completion Type
  if [[ "${curr_arg}" == */* ]]
  then
    # Store Symbolic Link
    local sym_link=$(_get_rname "${curr_arg}")

    # Store Trailing Path Component
    local trail_comp="${curr_arg##*/}"

    # Determine Subdirectory Locality
    local si=$((${#sym_link} + 1))
    local ei=$((${#curr_arg} - ${#trail_comp} - ${si}))

    # Store Subdirectory Path Component
    local sub_comp=${curr_arg:${si}:${ei}}

    # End Input Parsing----------------------------------------------------------------------------------------------------------------------------------------------

    # Initialize Resolved Directories
    local res_dirs=()

    # Resolve Linked Directories
    if [[ ! -d "${sym_link}" ]]
    then
      # Initialize Linked Paths
      local link_paths=${NSET}

      # Check For Indirect Link Matching
      if [[ -z $(command egrep -s -x "${sym_link}:.*" ${QCD_STORE} 2> /dev/null)  ]]
      then
        # Initialize Parameters
        local i=0 wld_link=${ESTR}

        # Check For Hidden Directory Prefix
        if [[ "${sym_link}" == \.* ]]
        then
          # Override Parameters
          i=1; wld_link="${BSLH}${CWD}"
        fi

        # Wildcard Symbolic Link
        for ((;i < ${#sym_link}; i++))
        do
          # Get Character At Index
          local c=${sym_link:${i}:1}

          # Append Wildcard
          wld_link="${wld_link}${c}.*"
        done

        # Set IFS
        local IFS=$'\n'

        # Get Sequence Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -i -x "${wld_link}:.*" ${QCD_STORE} 2> /dev/null)))
      else
        # Set IFS
        local IFS=$'\n'

        # Get Link Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -x "${sym_link}:.*" ${QCD_STORE} 2> /dev/null)))
      fi

      # End Linkage Acquisition--------------------------------------------------------------------------------------------------------------------------------------

      # Set IFS
      local IFS=$'\n'

      # Iterate Over Linked Paths
      for link_path in ${link_paths[@]}
      do
        # Substring Path From Delimiter
        link_path=$(_split_path "${link_path}")

        # Form Complete Path
        link_path=$(_escape_path "${link_path}${sub_comp}")

        # Add Resolved Directory
        if [[ -d "${link_path}" ]]
        then
          # Add Resolved Directory To List
          res_dirs+=($(command printf "%s\n" "${link_path}"))
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
      # Set IFS
      local IFS=$'\n'

      # Initialize Subdirectories
      local sub_dirs=()

      # Iterate Over Resolved Directories
      for res_dir in ${res_dirs[@]}
      do
        # Add Subdirectories Of Similar Visibility
        if [[ ! ${trail_comp:0:1} == ${CWD} ]]
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
      sym_link="${sym_link}${FLSH}"

      # Iterate Over Subdirectories
      for sub_dir in ${sub_dirs[@]}
      do
        # Generate Linked Subdirectory
        local link_sub=$(_escape_path "${sym_link}${sub_comp}${sub_dir%/}")

        # Determine Linked Subdirectory Locality
        if [[ ! -d "${link_sub}" ]]
        then
          # Append Completion Slash
          link_sub="${link_sub}${FLSH}"
        fi

        # Add Linked Subdirectories
        comp_list+=("${link_sub}")
      done

      # End Option Retrieval-----------------------------------------------------------------------------------------------------------------------------------------
    fi
  else
    # Get Symbolic Links From Store File
    local sym_links=$(command awk -F ':' '{print $1 "\n"}' ${QCD_STORE})

    # Get Current Directory Name
    local pwd=$(_get_dname "$(_get_pwd)")

    # Initialize Ignore Boolean
    local ignore_pwd=${FALSE}

    # End Linkage Acquisition----------------------------------------------------------------------------------------------------------------------------------------

    # Set IFS
    local IFS=$'\n'

    # Iterate Over Symbolic Links
    for sym_link in ${sym_links}
    do
      # Determine Symbolic Link Locality
      if [[ ! -d "${sym_link}" ]]
      then
        # Determine Action
        if [[ ${ignore_pwd} == ${FALSE} && "${sym_link}" == "${pwd}" ]]
        then
          # Exlude Current Directory
          ignore_pwd=${TRUE}
        elif [[ ${curr_arg:0:1} == ${CWD} && ${sym_link:0:1} == ${CWD} || ! ${curr_arg:0:1} == ${CWD} && ! ${sym_link:0:1} == ${CWD} ]]
        then
          # Add Symbolic Links Of Similar Visibility
          comp_list+=("${sym_link}${FLSH}")
        fi
      fi
    done

    # End Option Retrieval-------------------------------------------------------------------------------------------------------------------------------------------
  fi

  # Set IFS
  local IFS=$'\n'

  # Set Completion List
  COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${comp_list[@]}")" "${curr_arg}" 2> /dev/null))

  # End Option Generation--------------------------------------------------------------------------------------------------------------------------------------------
}

# End QCD Completion Function----------------------------------------------------------------------------------------------------------------------------------------

function _qcd_init() {
  # Check For Store File
  if [[ -f ${QCD_STORE} ]]
  then
    # Prepare Resource Files
    (qcd --clean &> /dev/null &)
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
