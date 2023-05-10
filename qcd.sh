# Developed by Nalin Ahuja, nalinahuja

# Boolean Values
readonly __TRUE=1 __FALSE=0 &> /dev/null

# Return Values
readonly __OK=0 __ERR=1 __CONT=2 __NSEL=255 &> /dev/null

# Keycode Values
readonly __ARR_UP=1 __ARR_DN=2 __ENTR=3 __EXIT=4 &> /dev/null

# Embedded Values
readonly __NULL=0 __MIN_PADDING=7 __TIME_DELAY=10 __COLUMN_NUM=1024 &> /dev/null

# End Numerical Constants--------------------------------------------------------------------------------------------------------------------------------------------

# Value Flags
readonly __ALIAS="-a" __OPTIONS="-o" __REMEMBER="-r" __FORGET="-f" __MKDIRENT="-m" &> /dev/null

# Command Flags
readonly __HELP="-h" __LIST="-l" __BACK="-b" __CLEAN="-c" __TRACK="-t" __UPDATE="-u" __VERSION="-v" &> /dev/null

# Embedded Strings
readonly  __CWD="." __HWD="../" __YES="y" __QUIT="q" __NSTR="" __FLSH="/" __BSLH="\\" __ESEQ=$(command printf "\033") &> /dev/null

# Control Sequences
readonly __CR="\r" __NL="\n" __CL=$(command printf "${__ESEQ}[K") __UP=$(command printf "${__ESEQ}[1A") __DN=$(command printf "${__ESEQ}[1B") &> /dev/null

# Text Formatting Strings
readonly __B=$(command printf "${__ESEQ}[1m") __W=$(command printf "${__ESEQ}[30m${__ESEQ}[47m") __N=$(command printf "${__ESEQ}(B${__ESEQ}[m") &> /dev/null

# End String Constants-----------------------------------------------------------------------------------------------------------------------------------------------

# Program Directory
readonly QCD_DIR=~/.qcd &> /dev/null

# Program Files
readonly QCD_SH=${QCD_DIR}/qcd.sh  &> /dev/null
readonly QCD_PL=${QCD_DIR}/rank.pl &> /dev/null

# Resource Files
readonly QCD_TEMP=${QCD_DIR}/.temp   &> /dev/null
readonly QCD_STORE=${QCD_DIR}/store  &> /dev/null
readonly QCD_TRACK=${QCD_DIR}/.track &> /dev/null

# Release Files
readonly QCD_VERSION=${QCD_DIR}/VERSION     &> /dev/null
readonly QCD_INSTALL=${QCD_DIR}/install.sh  &> /dev/null
readonly QCD_RELEASE=${QCD_DIR}/release.zip &> /dev/null

# End File Constants-------------------------------------------------------------------------------------------------------------------------------------------------

# Release URL Endpoint
readonly QCD_RELEASE_URL="https://api.github.com/repos/nalinahuja/qcd/releases/latest" &> /dev/null

# End Release Constants----------------------------------------------------------------------------------------------------------------------------------------------

# Exit Flag
declare QCD_EXIT=${__FALSE}

# Back Directory
declare QCD_BACK_DIR=${__NSTR}

# End Global Variables-----------------------------------------------------------------------------------------------------------------------------------------------

function is_empty() {
  # Check Argument Length
  if [[ ${1} -eq 0 ]]
  then
    # Return True
    command echo -e "${__TRUE}"
  fi
}

function _get_pwd() {
  # Store Present Working Directory
  local pwd=$(command pwd 2> /dev/null)

  # Conditionally Format Present Working Directory
  [[ ! "${pwd}" == "${__FLSH}" ]] && pwd+="${__FLSH}"

  # Return Present Working Directory
  command echo -e "${pwd}"
}

function _abs_path() {
  # Store Present Directory
  local pwd=$(_get_pwd)

  # Navigate To Argument Directory
  command cd "${@}"

  # Store Absolute Directory Path
  local abs_path=$(_get_pwd)

  # Navigate Back To Present Directory
  command cd "${pwd}"

  # Return Absolute Directory Path
  command echo -e "${abs_path}"
}

function _get_rname() {
  # Store Argument Directory
  local dir="${@%/}${__FLSH}"

  # Get Prefix String
  local pfx="${dir#*/*}"

  # Check Prefix String
  if [[ -n "${pfx}" ]]
  then
    # Determine Substring Bounds
    local si=0 ei=$((${#dir} - ${#pfx}))

    # Update Argument Directory
    dir="${dir:${si}:${ei}}"
  fi

  # Return Full Root Directory Name
  command echo -e "${dir%/}"
}

function _get_dname() {
  # Store Argument Directory
  local dir="${@%/}${__FLSH}"

  # Get Prefix String
  local pfx="${dir%/*/}"

  # Determine Substring Bounds
  local si=$((${#pfx} + 1))

  # Get Suffix String
  local sfx="${dir:${si}}"

  # Determine Return Format
  if [[ -z ${sfx} ]]
  then
    # Return Prefix String
    command echo -e "${pfx%/}"
  else
    # Return Suffix String
    command echo -e "${sfx%/}"
  fi
}

function _split_name() {
  # Return Name Of Symbolic Link
  command echo -e "${@%:*}"
}

function _split_path() {
  # Return Path Of Symbolic Link
  command echo -e "${@#*:}"
}

function _format_path() {
  # Check For Environment Variable
  if [[ -n "${HOME}" ]] && [[ "${@}" == ${HOME}* ]]
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

function _show_help() {
  # Display Help Message
  command echo -e "${__B}QCD Utility - $(_get_version)${__N}"

  # Display Usage Header
  command echo -e "${__NL}${__B}Usage:${__N}"

  # Display Usage
  command cat << EOF
  qcd                                 Switch to home directory
  qcd [dir]                           Switch to valid directory
  qcd [keyword]/[subdir]/...          Switch to linked directory
  qcd [n]..                           Switch to nth parent directory
  qcd [file]                          Switch to valid file directory
EOF

  # Display Options Header
  command echo -e "${__NL}${__B}Options:${__N}"

  # Display Options
  command cat << EOF
  qcd [-h, --help]                    Show this help
  qcd [-c, --clean]                   Clean store file
  qcd [-l, --list]                    List stored linkages
  qcd [-v, --version]                 Show current version
  qcd [-u, --update]                  Update to latest version
  qcd [-b, --back-dir]                Navigate to backward directory
  qcd [-t, --track-dirs]              Set directory tracking behavior

  qcd [-r, --remember]                Remember present directory
  qcd [-r, --remember] [dir]          Remember directory by path
  qcd [-a, --alias] [alias]           Remember present directory by alias

  qcd [-f, --forget]                  Forget present directory
  qcd [-f, --forget] [dir]            Forget matching directory path
  qcd [-f, --forget] [keyword]        Forget matching symbolic linkages

  qcd [-m, --mkdir] [dir]             Create and switch to new directory
  qcd [-o, --options] [query]         Show symbolic linkage options in menu

Developed by Nalin Ahuja, nalinahuja
EOF
}

function _get_version() {
  # Return Installation Version
  command cat ${QCD_VERSION} 2> /dev/null
}

# End Resource Functions---------------------------------------------------------------------------------------------------------------------------------------------

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

# End Environment Functions------------------------------------------------------------------------------------------------------------------------------------------

function _read_input() {
  # Initialize String Buffer
  local buffer=()

  # Read Input Stream
  while [[ 1 ]]; do
    # Read One Character From STDIN
    command read -s -n1 c 2> /dev/null

    # Return Enter Action
    [[ "${c}" == "${__NSTR}" ]] && command echo -e "${__ENTR}" && break

    # Return Quit Action
    [[ "${c}" == "${__QUIT}" ]] && command echo -e "${__EXIT}" && break

    # Append Character To Input Buffer
    buffer+=("${c}")

    # Reset String Buffer
    [[ ! "${buffer[0]}" == "${__ESEQ}" ]] && buffer=()

    # Check Break Conditions
    if [[ ${#buffer[@]} -ge 3 ]]
    then
      # Set IFS
      local IFS=$''

      # Return Up Arrow Action
      [[ "${buffer[*]}" == "${__ESEQ}[A" ]] && command echo -e "${__ARR_UP}" && break

      # Return Down Arrow Action
      [[ "${buffer[*]}" == "${__ESEQ}[B" ]] && command echo -e "${__ARR_DN}" && break

      # Reset String Buffer
      buffer=()

      # Unset IFS
      unset IFS
    fi
  done
}

function _clear_output() {
  # Clear Line Entries
  for ((li=0; li <= ${1}; li++)); do
    # Go To Beginning Of Line
    command printf "${__ESEQ}[${__COLUMN_NUM}D"

    # Clear Line
    command printf "${__CL}"

    # Go Up One Line
    command printf "${__UP}"
  done

  # Go Down One Line
  command printf "${__DN}"
}

function _generate_menu() {
  # Hide Terminal Outputs
  _hide_output

  # Set Signal Trap For SIGINT
  command trap _qcd_exit SIGINT &> /dev/null

  # Reset Exit Flag
  QCD_EXIT=${__FALSE}

  # Initialize String Buffer
  local buffer=()

  # Initialize Selected Option
  local os=${__NULL}

  # Begin Selection Loop
  while [[ 1 ]]; do
    # Initialize Option Index
    local oi=${__NULL}

    # Iterate Over Options
    for opt in "${@}"; do
      # Format Option
      opt=$(_format_path "${opt%/}")

      # Conditionally Format Option
      if [[ ${oi} -eq ${os} ]]
      then
        # Format Option As Selected
        buffer+=($(command echo -e "${__W} ${opt} ${__N}"))
      else
        # Format Option As Unselected
        buffer+=($(command echo -e " ${opt} "))
      fi

      # Increment Option Index
      ((oi++))
    done

    # Display Selection
    command echo -e "${buffer[*]}"

    # Read User Input
    local key=$(_read_input)

    # Clear String Buffer
    buffer=()

    # Check Exit Flag
    if [[ ${QCD_EXIT} -eq ${__TRUE} ]]
    then
      # Reset Exit Flag
      QCD_EXIT=${__FALSE}

      # Reset Selected Option
      os=${__NSEL}

      # Break Loop
      break
    fi

    # Update Cursor Position
    if [[ ${key} -eq ${__ARR_UP} ]]
    then
      # Decrement Selected Option
      ((os--))
    elif [[ ${key} -eq ${__ARR_DN} ]]
    then
      # Increment Selected Option
      ((os++))
    elif [[ ${key} -eq ${__ENTR} ]]
    then
      # Break Loop
      break
    elif [[ ${key} -eq ${__EXIT} ]]
    then
      # Reset Option Selection
      os=${__NSEL}

      # Break Loop
      break
    fi

    # Check For Option Loopback
    if [[ ${os} -eq ${#@} ]]
    then
      # Jump To Top
      os=0
    elif [[ ${os} -eq -1 ]]
    then
      # Jump To Bottom
      os=$((${#@} - 1))
    fi

    # Clear Previous Selection
    _clear_output ${#@}
  done

  # Clear Signal Trap For SIGINT
  command trap - SIGINT &> /dev/null

  # Clear Selection Interface
  _clear_output $((${#@} + 1))

  # Show Terminal Outputs
  _show_output

  # Return Selected Option
  return ${os}
}

# End User Inferface Functions---------------------------------------------------------------------------------------------------------------------------------------

function _create_store() {
  # Check For Store File
  if [[ ! -f "${QCD_STORE}" ]]
  then
    # Create Store File
    command touch ${QCD_STORE} 2> /dev/null

    # Return To Caller
    return ${?}
  fi

  # Return To Caller
  return ${__OK}
}

function _update_store() {
  # Check Exit Status
  if [[ ${1} -eq ${__OK} ]]
  then
    # Update Store File
    command mv ${QCD_TEMP} ${QCD_STORE} 2> /dev/null
  fi

  # Cleanup Temp
  _cleanup_temp

  # Return To Caller
  return ${__OK}
}

function _cleanup_temp() {
  # Check For Temp File
  if [[ -f "${QCD_TEMP}" ]]
  then
    # Remove Temp File
    command rm ${QCD_TEMP} 2> /dev/null
  fi

  # Return To Caller
  return ${__OK}
}

# End File Management Functions--------------------------------------------------------------------------------------------------------------------------------------

function _add_directory() {
  # Initialize Directory Path
  local dir=${__NSTR}

  # Check For Argument Path
  if [[ $(is_empty ${#@}) ]]
  then
    # Store Current Path
    dir=$(_get_pwd)
  else
    # Store Argument Path
    dir="${1}"
  fi

  # Compare Directory Path To Home Path
  [[ "${dir%/}" == "${HOME%/}" ]] && return ${__OK}

  # Initialize Path Endpoint
  local ept=${__NSTR}

  # Check For Argument Endpoint
  if [[ ${#@} -lt 2 ]]
  then
    # Extract Endpoint From Directory Path
    ept=$(_get_dname "${dir}")
  else
    # Store Argument Endpoint
    ept="${2}"

    # Format Argument Endpoint
    ept="${ept%/}"
  fi

  # Initialize Data Characteristics
  local udir=${__FALSE} uent=${__FALSE}

  # Determine If Linkage Directory Is Unique
  [[ -z $(command awk -F ':' -v DIR="${dir}" '{if ($2 == DIR) {print $0}}' ${QCD_STORE} 2> /dev/null) ]] && udir=${__TRUE}

  # Determine If Linkage Entry Is Unique
  [[ -z $(command awk -F ':' -v EPT="${ept}" -v DIR="${dir}" '{if ($1 == EPT && $2 == DIR) {print $0}}' ${QCD_STORE} 2> /dev/null) ]] && uent=${__TRUE}

  # Store Directory As Linkage
  if [[ ${udir} -eq ${__TRUE} ]] || [[ ${uent} -eq ${__TRUE} ]]
  then
    # Check Linkage Characteristic
    if [[ ${uent} -eq ${__TRUE} ]]
    then
      # Remove Linkage By Directory
      _remove_directory "${dir}"
    fi

    # Append Data To Store File
    command echo -e "${ept}:${dir}" >> ${QCD_STORE}

    # Sort Store File In Place
    command sort -o ${QCD_STORE} -n -t ':' -k2 ${QCD_STORE}
  fi

  # Return To Caller
  return ${__OK}
}

function _remove_linkage() {
  # Store Argument Link
  local link=$(_escape_regex "${@%/}")

  # Remove Link From Store File
  command awk -F ':' -v LINK="${link}" '{if ($1 != LINK) {print $0}}' ${QCD_STORE} >| ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}

  # Return To Caller
  return ${__OK}
}

function _remove_directory() {
  # Initialize Directory Path
  local dir=${__NSTR}

  # Check For Argument Path
  if [[ $(is_empty ${#@}) ]]
  then
    # Store Current Path
    dir=$(_get_pwd)
  else
    # Store Argument Path
    dir="${@}"
  fi

  # Remove Directory From Store File
  command awk -F ':' -v DIR="${dir}" '{if ($2 != DIR) {print $0}}' ${QCD_STORE} >| ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}

  # Return To Caller
  return ${__OK}
}

# End Linkage Management Functions-----------------------------------------------------------------------------------------------------------------------------------

function _parse_arguments() {
  # Intialize Directory Parameters
  local dir=${__NSTR} als=${__NSTR}

  # Parse Arguments
  while [[ ! $(is_empty ${#@}) ]]; do
    # Determine Action
    case "${1}" in
      # Check For Help Flag
      ${__HELP}|--help)
        # Display Help Message
        _show_help

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Version Flag
      ${__VERSION}|--version)
        # Display Installation Version
        _show_help | command head -n1

        # Terminate Program
        return ${__OK}
      ;;

      # Check For List Flag
      ${__LIST}|--list)
        # Display Prompt
        command echo -en "${__CR}${__CL}qcd: Generating linkage map..."

        # Get Symbolic Linkages From Store File
        local sym_links=$(qcd --clean &> /dev/null && command cat ${QCD_STORE})

        # Error Check Symbolic Linkages
        if [[ -z ${sym_links} ]]
        then
          # Display Prompt
          command echo -e "${__CR}${__CL}qcd: No linkages found"

          # Terminate Program
          return ${__ERR}
        fi

        # Determine Column Values
        local tcols=$(command tput cols)

        # Determine Column Padding
        local pcols=$(command echo -e "${sym_links}" | command awk -F ':' '{print length($1)}' | command sort -n | command tail -n1)

        # Set Column Padding To Minimum
        [[ ${pcols} -lt ${__MIN_PADDING} ]] && pcols=${__MIN_PADDING}

        # Format Table Header
        command printf "${__CR}${__W} %-${pcols}s  %-$((${tcols} - ${pcols} - 3))s${__N}${__NL}" "Keyword" "Directory" >| ${QCD_TEMP}

        # Set IFS
        local IFS=$'\n'

        # Iterate Over Linkages
        for sym_link in ${sym_links}; do
          # Extract Linkage Component
          local link=$(_split_name "${sym_link}")

          # Extract Path Component
          local path=$(_format_path "$(_split_path "${sym_link}")")

          # Format Path Component
          [[ ! ${path} == ${__FLSH} ]] && path="${path%/}"

          # Format Linkage Row
          command printf " %-${pcols}s  %s${__NL}" "${link}" "${path}" >> ${QCD_TEMP}
        done

        # Unset IFS
        unset IFS

        # Display Linkage Table
        command cat ${QCD_TEMP}

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Clean Flag
      ${__CLEAN}|--clean)
        # Set IFS
        local IFS=$'\n'

        # Get Linkage Paths
        local link_paths=($(command awk -F ':' '{print $2}' ${QCD_STORE}))

        # Iterate Over Linkage Paths
        for link_path in ${link_paths[@]}; do
          # Verify Linkage Path
          if [[ ! -d "${link_path}" ]]
          then
            # Remove Invalid Linkage Path
            (_remove_directory "${link_path}" &> /dev/null)
          fi
        done

        # Unset IFS
        unset IFS

        # Display Prompt
        command echo -e "qcd: Cleaned linkages in store file"

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Update Flag
      ${__UPDATE}|--update)
        # Display Prompt
        command echo -e "qcd: Currently running ${__B}$(_get_version)${__N}"

        # Prompt User For Confirmation
        command read -p "→ Confirm update [y/n]: " confirm

        # Determine Action
        if [[ "$(command awk '{print tolower($0)}' <<< ${confirm})" == "${__YES}" ]]
        then
          # Clear Previous Outputs
          _clear_output 1

          # Verify Curl Dependency
          if [[ -z "$(command -v curl)" ]]
          then
            # Display Prompt
            command echo -e "→ ${__B}curl${__N} dependency not installed"

            # Terminate Program
            return ${__ERR}
          fi

          # Display Prompt
          command echo -en "→ Downloading update "

          # Get Release Information
          local release_info=$(command curl --connect-timeout ${__TIME_DELAY} -sL ${QCD_RELEASE_URL} 2> /dev/null)

          # Get Download URL
          local download_url=$(command echo -e "${release_info}" | command egrep -s -o "https.*zipball.*" 2> /dev/null | command awk -F '"' '{print $1}' 2> /dev/null)

          # Verify Download URL
          if [[ ${?} -ne ${__OK} ]] || [[ -z ${download_url} ]]
          then
            # Display Prompt
            command echo -e "${__CR}${__CL}→ Failed to resolve download source for update"

            # Terminate Program
            return ${__ERR}
          fi

          # Download Release Contents
          command curl --connect-timeout ${__TIME_DELAY} -sL "${download_url}" >| ${QCD_RELEASE}

          # Error Check Release Contents
          if [[ ${?} -ne ${__OK} ]] || [[ ! -f "${QCD_RELEASE}" ]]
          then
            # Display Prompt
            command echo -e "${__CR}${__CL}→ Failed to download update"

            # Terminate Program
            return ${__ERR}
          fi

          # Display Prompt
          command echo -en "${__CR}${__CL}→ Installing updates "

          # Uninstall Old Program Files
          command rm ${QCD_DIR}/*.sh ${QCD_DIR}/*.pl

          # Install New Program Files
          command unzip -o -j ${QCD_RELEASE} -d ${QCD_DIR} &> /dev/null

          # Error Check Installation
          if [[ ${?} -ne ${__OK} ]]
          then
            # Display Prompt
            command echo -e "${__CR}${__CL}→ Failed to install update"

            # Terminate Program
            return ${__ERR}
          fi

          # Cleanup Installation
          command rm ${QCD_RELEASE} ${QCD_INSTALL} 2> /dev/null

          # Display Prompt
          command echo -en "${__CR}${__CL}→ Configuring updates "

          # Update Terminal Environment
          command source ${QCD_SH} 2> /dev/null

          # Error Check Installation
          if [[ ${?} -ne ${__OK} ]]
          then
            # Display Prompt
            command echo -e "${__CR}${__CL}→ Failed to configure update"

            # Terminate Program
            return ${__ERR}
          fi

          # Display Prompt
          command echo -e "${__CR}${__CL}→ Update complete "

          # Clear Previous Outputs
          _clear_output 2

          # Display Prompt
          command echo -e "qcd: Updated to ${__B}$(_get_version)${__N}"
        else
          # Clear All Outputs
          _clear_output 2
        fi

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Back Flag
      ${__BACK}|--back-dir)
        # Check Back Directory Variable
        if [[ -n "${QCD_BACK_DIR}" ]] && [[ -d "${QCD_BACK_DIR}" ]]
        then
          # Get Current Directory
          local pwd=$(_get_pwd)

          # Switch To Back Directory
          command cd "${QCD_BACK_DIR}"

          # Update Back Directory
          QCD_BACK_DIR="${pwd}"

          # Terminate Program
          return ${__OK}
        else
          # Display Prompt
          command echo -e "qcd: Could not navigate to directory"

          # Terminate Program
          return ${__ERR}
        fi
      ;;

      # Check For Tracking Flag
      ${__TRACK}|--track-dir)
        # Check For Tracking File
        if [[ -f "${QCD_TRACK}" ]]
        then
          # Display Prompt
          command echo -e "qcd: Directory tracking ${__B}enabled${__N}"

          # Prompt User For Confirmation
          command read -p "→ Disable tracking [y/n]: " confirm
        else
          # Display Prompt
          command echo -e "qcd: Directory tracking ${__B}disabled${__N}"

          # Prompt User For Confirmation
          command read -p "→ Enable tracking [y/n]: " confirm
        fi

        # Clear Previous Outputs
        _clear_output 2

        # Determine Action
        if [[ "$(command awk '{print tolower($0)}' <<< ${confirm})" == "${__YES}" ]]
        then
          # Check For Tracking File
          if [[ ! -f "${QCD_TRACK}" ]]
          then
            # Create Tracking File
            command touch ${QCD_TRACK}

            # Display Prompt
            command echo -e "qcd: Directory tracking ${__B}enabled${__N}"
          else
            # Remove Tracking File
            command rm ${QCD_TRACK}

            # Display Prompt
            command echo -e "qcd: Directory tracking ${__B}disabled${__N}"
          fi
        fi

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Make Directory Flag
      ${__MKDIRENT}|--make-dir)
        # Shift Past Flag
        command shift

        # Verify Path Argument
        if [[ -z ${1} ]] || [[ "${1}" == -* ]]
        then
          # Display Prompt
          command echo -e "qcd: Directory path missing"

          # Terminate Program
          return ${__ERR}
        fi

        # Store Directory Path
        local dir_path="${1}"

        # Store Trailing Path
        local trail_path=$(_get_dname "${dir_path}")

        # Determine Substring Bounds
        local si=0 ei=$((${#dir_path} - ${#trail_path}))

        # Store Prefix Path Component
        local pfx_path="${dir_path:${si}:${ei}}"

        # Verify Path Components
        if [[ -d "${dir_path}" ]]
        then
          # Display Prompt
          command echo -e "qcd: Directory already exists"

          # Terminate Program
          return ${__ERR}
        fi

        # Create Directory At Location
        command mkdir -p "${dir_path}"

        # Switch To New Directory
        command cd "${dir_path}"

        # Add Current Directory If Tracking
        [[ -f "${QCD_TRACK}" ]] && (_add_directory &> /dev/null &)

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Remember Flag
      ${__REMEMBER}|--remember)
        # Determine Remember Type
        if [[ -z ${2} ]] || [[ "${2}" == -* ]]
        then
          # Get Current Directory
          dir=$(_get_pwd)
        else
          # Get Argument Directory
          dir="${2}"

          # Verify Argument Directory
          if [[ ! -d "${dir}" ]]
          then
            # Display Prompt
            command echo -e "qcd: Invalid directory path"

            # Terminate Program
            return ${__ERR}
          fi

          # Shift Past Flag
          command shift
        fi

        # Shift Past Value
        command shift
      ;;

      # Check For Forget Flag
      ${__FORGET}|--forget)
        # Initalize Argument
        local arg="${2}"

        # Determine Forget Type
        if [[ -z ${arg} ]]
        then
          # Forget Current Directory
          (_remove_directory &> /dev/null &)
        elif [[ ! -d "${arg}" ]]
        then
          # Forget Argument As Linkage
          (_remove_linkage "${arg}" &> /dev/null &)
        else
          # Expand Directory Path
          arg=$(_abs_path "${arg}")

          # Forget Argument As Directory
          (_remove_directory "${arg}" &> /dev/null &)
        fi

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Alias Flag
      ${__ALIAS}|--alias)
        # Shift Past Flag
        command shift

        # Verify Alias Argument
        if [[ -z ${1} ]] || [[ "${1}" == -* ]]
        then
          # Display Prompt
          command echo -e "qcd: Directory alias missing"

          # Terminate Program
          return ${__ERR}
        fi

        # Get Argument Alias
        als=$(_escape_regex "${1}")

        # Shift Past Value
        command shift
      ;;

      # Check For Option Flag
      ${__OPTIONS}|--options)
        # Shift Past Flag
        command shift

        # Verify Option Argument
        if [[ -z ${1} ]] || [[ "${1}" == -* ]]
        then
          # Display Prompt
          command echo -e "qcd: Directory linkage missing"

          # Terminate Program
          return ${__ERR}
        fi
      ;;

      # Default Flag Handler
      -*)
        # Display Prompt
        command echo -e "qcd: ${1}: Unsupported commandline flag"

        # Terminate Program
        return ${__ERR}
      ;;

      # Default Argument Handler
      *)
        # Shift Past Value
        command shift
      ;;
    esac
  done

  # Verify Directory Parameters
  if [[ -n "${dir}" ]] || [[ -n "${als}" ]]
  then
    # Verify Directory Parameter
    [[ -z ${dir} ]] && dir=$(_get_pwd)

    # Verify Alias Parameter
    [[ -z ${als} ]] && als=$(_get_dname $(_abs_path "${dir}"))

    # Expand Directory Path
    dir=$(_abs_path "${dir}")

    # Add Directory To Store File
    (_add_directory "${dir}" "${als}" &> /dev/null &)

    # Terminate Program
    return ${__OK}
  fi

  # Continue Program
  return ${__CONT}
}

# End Argument Parser Function---------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Create Resource File
  _create_store

  # Store Creation Status
  local status=${?}

  # Check For Terminating Status
  [[ ${status} -ne ${__OK} ]] && return ${status}

  # Parse Commandline Arguments
  _parse_arguments "${@}"

  # Store Parsing Status
  local status=${?}

  # Check For Terminating Status
  [[ ${status} -ne ${__CONT} ]] && return ${status}

  # Initialize Argument Components
  local dir_arg=~ opt_arg=${__FALSE}

  # Check Argument Validity
  if [[ -n "${@}" ]]
  then
    # Store Argument
    local arg="${@:1:1}"

    # Initialize Sublist Bounds
    local si=1 ei=${#@}

    # Process Argument
    case "${arg}" in
      # Check For Option Flag
      ${__OPTIONS}|--options)
        # Update Sublist Bounds
        si=2; ei=${#@};

        # Set Option Argument
        opt_arg=${__TRUE}
      ;;
    esac

    # Set Directory Argument
    dir_arg="${@:${si}:${ei}}"

    # Check For Back Directory Pattern
    if [[ "${dir_arg}" =~ [0-9]+\.\. ]]
    then
      # Determine Substring Bounds
      local si=0 ei=$((${#dir_arg} - 2))

      # Determine Directory Offset
      local offset="${dir_arg:${si}:${ei}}"

      # Generate Directory Offset Pattern
      local format=$(command printf "%${offset}s" 2> /dev/null)

      # Replace Directory Argument
      dir_arg="${format// /${__HWD}}"

      # Override Option Argument
      opt_arg=${__FALSE}
    else
      # Check If Directory Argument Is A File Path
      if [[ -f "${dir_arg}" ]]
      then
        # Convert File Path To Directory Path
        dir_arg=$(command dirname "${dir_arg}")
      fi

      # Format Escaped Characters
      dir_arg=$(_escape_path "${dir_arg}")
    fi
  fi

  # Get Old Present Directory
  local old_pwd=$(_get_pwd)

  # Determine If Directory Is Linked
  if [[ -d "${dir_arg}" ]] && [[ ${opt_arg} -eq ${__FALSE} ]]
  then
    # Change To Valid Directory
    command cd "${dir_arg}"

    # Get New Present Directory
    local new_pwd=$(_get_pwd)

    # Add Current Directory If Tracking
    [[ -f "${QCD_TRACK}" ]] && (_add_directory &> /dev/null &)

    # Set Back Directory On Path Mismatch
    [[ ! "${old_pwd}" == "${new_pwd}" ]] && QCD_BACK_DIR="${old_pwd}"

    # Terminate Program
    return ${__OK}
  else
    # Initialize Subdirectory Component
    local sub_link=${__NSTR}

    # Initialize Prefix Length
    local pfx_len=${#dir_arg}

    # Determine Linked Subdirectory
    if [[ "${dir_arg}" == */* ]]
    then
      # Extract Subdirectory Subdirectory
      sub_link="${dir_arg#*/}"

      # Update Prefix Length
      pfx_len=$((${pfx_len} - ${#sub_link} - 1))
    fi

    # Set IFS
    local IFS=$'\n'

    # Initialize Symbolic Link Component
    local sym_link=$(_escape_regex "${dir_arg:0:${pfx_len}}")

    # Get Exact Matched Symbolic Paths From Store File
    local pathv=($(command awk -F ':' -v LINK="${sym_link}" '{if (LINK == $1) {print $2}}' ${QCD_STORE} 2> /dev/null))

    # Check For Indirect Link Matching
    if [[ $(is_empty ${#pathv[@]}) ]]
    then
      # Initialize Parameters
      local i=0 wld_link=${__NSTR}

      # Check For Hidden Directory Prefix
      if [[ "${sym_link}" == \\.* ]]
      then
        # Override Parameters
        i=2; wld_link="${__BSLH}${__CWD}";
      fi

      # Wildcard Symbolic Link
      for ((; i < ${#sym_link}; i++)); do
        # Get Character At Index
        local c="${sym_link:${i}:1}"

        # Append Wildcard
        wld_link="${wld_link}${c}.*"
      done

      # Get Subsequence Matched Symbolic Paths From Store File
      pathv=($(command egrep -i -s -x "${wld_link}:.*" ${QCD_STORE} 2> /dev/null))
    fi

    # Initialize Path Count
    local pathc=${#pathv[@]}

    # Check Result Count
    if [[ ${pathc} -gt 1 ]]
    then
      # Initialize Path List
      local paths=()

      # Store Current Directory
      local pwd=$(_get_pwd)

      # Iterate Over Path Values
      for path in ${pathv[@]}; do
        # Split Path By Delimiter
        path=$(_split_path "${path}")

        # Concatenate Subdirectory Path
        path=$(_escape_path "${path}${sub_link}")

        # Verify Path
        if [[ -d "${path}" ]] && [[ ! "${path%/}" == "${pwd%/}" ]]
        then
          # Add Path To List
          paths+=($(command echo "${path}"))
        fi
      done

      # Update Path Count
      pathc=${#paths[@]}

      # List Matching Paths
      if [[ ${pathc} -gt 1 ]] && [[ -n "${paths}" ]]
      then
        # Display Prompt
        command echo -e "qcd: Multiple paths linked to ${__B}${dir_arg%/}${__N}"

        # Determine Ordering Method
        if [[ -x "$(command -v perl)" ]]
        then
          # Order Paths By Longest Common Subsequence
          paths=($(command perl ${QCD_PL} "${dir_arg}" "${paths[@]}"))
        else
          # Initialize Path Lists
          local pfxm=() pfxf=()

          # Iterate Over Filtered Paths
          for path in ${paths[@]}; do
            # Get Path Endpoint
            local ept=$(_get_dname "${path}")

            # Compare Endpoint To Directory Argument
            if [[ "${ept}" == ${dir_arg}* ]]
            then
              # Add Path To Match List
              pfxm+=("${path}")
            else
              # Add Path To Fail List
              pfxf+=("${path}")
            fi
          done

          # Concatenate Path Lists
          paths=("${pfxm[@]}" "${pfxf[@]}")
        fi

        # Generate Selection Menu
        _generate_menu ${paths[@]}

        # Store Selection Status
        local ept=${?}

        # Check Selection Status
        [[ ${ept} -eq ${__NSEL} ]] && return ${__OK}

        # Set To Manually Selected Endpoint
        pathv="${paths[${ept}]}"
      else
        # Set To Automatically Selected Endpoint
        pathv="${paths}"
      fi
    else
      # Substring Path From Delimiter
      pathv=$(_split_path "${pathv}")
    fi

    # Error Check Result
    if [[ -z ${pathv} ]]
    then
      # Display Error
      command echo -e "qcd: Could not navigate to directory"

      # Terminate Program
      return ${__ERR}
    elif [[ ! -d "${pathv}" ]]
    then
      # Conditionally Print Separator
      [[ ${pathc} -gt 1 ]] && command echo

      # Remove Current Directory
      (_remove_directory "${pathv}" &> /dev/null &)

      # Display Error
      command echo -e "qcd: $(_format_path "${pathv%/}"): Directory does not exist"

      # Terminate Program
      return ${__ERR}
    else
      # Update Back Directory
      QCD_BACK_DIR=$(_get_pwd)

      # Switch To Linked Path
      command cd "${pathv}"

      # Validate Subdirectory Component
      if [[ -n "${sub_link}" ]]
      then
        # Extract Trailing Path Component
        local trail_comp="${sub_link##*/}"

        # Determine Leading Path Locality
        local si=0 ei=$((${#sub_link} - ${#trail_comp}))

        # Extract Leading Path Component
        local lead_comp="${sub_link:${si}:${ei}}"

        # Validate Leading Path Component
        if [[ -z ${lead_comp} ]]
        then
          # Update Path Components
          lead_comp="${trail_comp}"; trail_comp=${__NSTR};
        fi

        # Validate Leading Path Existence
        if [[ -n "${lead_comp}" ]] && [[ -d "${lead_comp}" ]]
        then
          # Switch To Leading Path
          command cd "${lead_comp}"

          # Validate Trailing Path Existence
          if [[ -n "${trail_comp}" ]] && [[ -d "${trail_comp}" ]]
          then
            # Switch To Trailing Path
            command cd "${trail_comp}"
          fi
        fi

        # Get New Present Directory
        local new_pwd=$(_get_pwd)

        # Add Current Directory If Tracking
        [[ -f "${QCD_TRACK}" ]] && (_add_directory &> /dev/null &)

        # Set Back Directory On Path Mismatch
        [[ ! "${old_pwd}" == "${new_pwd}" ]] && QCD_BACK_DIR="${old_pwd}"
      fi

      # Terminate Program
      return ${__OK}
    fi

    # Unset IFS
    unset IFS
  fi
}

# End QCD Function---------------------------------------------------------------------------------------------------------------------------------------------------

function _qcd_comp() {
  # Create Resource File
  _create_store

  # Set IFS
  local IFS=$'\n'

  # Initialize Completion List
  local comp_list=()

  # Store Current Argument
  local curr_arg=${COMP_WORDS[COMP_CWORD]}

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
    local sub_comp="${curr_arg:${si}:${ei}}"

    # Resolve Linked Directories
    if [[ ! -d "${sym_link}" ]]
    then
      # Get Exact Matched Symbolic Paths From Store File
      local link_paths=($(command awk -F ':' -v LINK="${sym_link}" '{if (LINK == $1) {print $2}}' ${QCD_STORE} 2> /dev/null))

      # Check For Indirect Link Matching
      if [[ $(is_empty ${#link_paths[@]}) ]]
      then
        # Initialize Parameters
        local i=0 wld_link=${__NSTR}

        # Check For Hidden Directory Prefix
        if [[ "${sym_link}" == \\.* ]]
        then
          # Override Parameters
          i=2; wld_link="${__BSLH}${__CWD}";
        fi

        # Wildcard Symbolic Link
        for ((; i < ${#sym_link}; i++)); do
          # Get Character At Index
          local c="${sym_link:${i}:1}"

          # Append Wildcard
          wld_link="${wld_link}${c}.*"
        done

        # Get Subsequence Matched Symbolic Paths From Store File
        link_paths=($(command egrep -i -s -x "${wld_link}:.*" ${QCD_STORE} 2> /dev/null))
      fi

      # Initialize Resolved Directories
      local res_dirs=()

      # Iterate Over Linked Paths
      for link_path in ${link_paths[@]}; do
        # Substring Path From Delimiter
        link_path=$(_split_path "${link_path}")

        # Form Complete Path
        link_path=$(_escape_path "${link_path}${sub_comp}")

        # Add Resolved Directory
        if [[ -d "${link_path}" ]]
        then
          # Add Resolved Directory
          res_dirs+=($(command printf "%s${__NL}" "${link_path}"))
        fi
      done
    else
      # Resolve Local Directories
      res_dirs=$(_escape_path "${curr_arg}")
    fi

    # Error Check Resolved Directory
    if [[ -n "${res_dirs}" ]]
    then
      # Initialize Subdirectories
      local sub_dirs=()

      # Get Trailing Component Prefix
      local tc_pfx="${trail_comp:0:1}"

      # Add Subdirectories Of Similar Visibility
      if [[ ! "${tc_pfx}"  == "${__CWD}" ]]
      then
        # Iterate Over Resolved Directories
        for res_dir in ${res_dirs[@]}; do
          # Add Visible Linked Subdirectories
          sub_dirs+=($(command ls -F "${res_dir}" 2> /dev/null | command egrep -s -x ".*/" 2> /dev/null))
        done
      else
        # Iterate Over Resolved Directories
        for res_dir in ${res_dirs[@]}; do
          # Add Hidden Linked Subdirectories
          sub_dirs+=($(command ls -aF "${res_dir}" 2> /dev/null | command egrep -s -x ".*/" 2> /dev/null))
        done
      fi

      # Format Symbolic Link
      sym_link="${sym_link}${__FLSH}"

      # Iterate Over Subdirectories
      for sub_dir in ${sub_dirs[@]}; do
        # Generate Linked Subdirectory
        local link_sub=$(_escape_path "${sym_link}${sub_comp}${sub_dir%/}")

        # Append Completion Delimiter
        [[ ! -d "${link_sub}" ]] && link_sub="${link_sub}${__FLSH}"

        # Add Linked Subdirectories
        comp_list+=("${link_sub}")
      done
    fi
  else
    # Get Current Directory
    local pwd=$(_get_pwd)

    # Get Current Argument Prefix
    local ca_pfx="${curr_arg:0:1}"

    # Get Nonlocal Symbolic Links From Store File
    local sym_links=($(command awk -v pwd="${pwd}" -F ':' '{if ($2 != pwd) {print $1}}' ${QCD_STORE}))

    # Iterate Over Symbolic Links
    for sym_link in ${sym_links[@]}; do
      # Get Symbolic Link Prefix
      local sl_pfx="${sym_link:0:1}"

      # Determine Symbolic Link Locality
      if [[ ! -d "${sym_link}" ]]
      then
        # Determine Symbolic Link Visibility
        if [[ "${ca_pfx}" == "${__CWD}" && "${sl_pfx}" == "${__CWD}" ]] || [[ ! "${ca_pfx}" == "${__CWD}" && ! "${sl_pfx}" == "${__CWD}" ]]
        then
          # Add Symbolic Link
          comp_list+=("${sym_link}${__FLSH}")
        fi
      fi
    done
  fi

  # Set Completion List
  COMPREPLY=($(command compgen -W "$(command printf "%s${__NL}" "${comp_list[@]}")" "${curr_arg}" 2> /dev/null))

  # Unset IFS
  unset IFS
}

function _qcd_init() {
  # Set Signal Trap For EXIT
  command trap _cleanup_temp EXIT &> /dev/null

  # Set Environment To Show Visible Files
  command bind 'set match-hidden-files off' &> /dev/null

  # Initialize Directory Completion Engine
  command complete -o nospace -o filenames -o bashdefault -A directory -F _qcd_comp qcd

  # Remove Invalid Linkages From Store File
  [[ -f "${QCD_STORE}" ]] && (qcd --clean &> /dev/null &)
}

function _qcd_exit() {
  # Set Exit Flag
  QCD_EXIT=${__TRUE}
}

# End QCD Dependency Functions---------------------------------------------------------------------------------------------------------------------------------------

# Initialize QCD
_qcd_init

# End QCD Program Source---------------------------------------------------------------------------------------------------------------------------------------------
