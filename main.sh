# Boolean Values
readonly __TRUE=1 __FALSE=0 &> /dev/null

# Keycode Values
readonly __UP=1 __DN=2 __ENT=3 __EXT=4 &> /dev/null

# Return Values
readonly __OK=0 __ERR=1 __CONT=2 __NSEL=255 &> /dev/null

# Embedded Values
readonly __NSET=0 __MINPAD=5 __TIMEOUT=10 __COLNUM=256 &> /dev/null

# End Numerical Constants--------------------------------------------------------------------------------------------------------------------------------------------

# Option Flags
readonly __ALIAS="-a" __OPTIONS="-o" __REMEMBER="-r" __FORGET="-f" __MKDIRENT="-m" &> /dev/null

# Standalone Flags
readonly __HELP="-h" __LIST="-l" __BACK="-b" __CLEAN="-c" __TRACK="-t" __UPDATE="-u" __VERSION="-v" &> /dev/null

# Embedded Strings
readonly __CWD="." __HWD="../" __YES="y" __QUIT="q" __ESTR="" __FLSH="/" __BSLH="\\" _ESEQ=$(command printf "\033") &> /dev/null

# Text Formatting Strings
readonly __B=$(command printf "${_ESEQ}[1m") __W=$(command printf "${_ESEQ}[30m${_ESEQ}[47m") __N=$(command printf "${_ESEQ}(B${_ESEQ}[m") &> /dev/null

function _read_input() {
  # Initialize String Buffer
  local buffer=()

  # Read Input Stream
  while [[ 1 ]]
  do
    # Read One Character From STDIN
    command read -s -n1 c 2> /dev/null

    # Return Enter Action
    [[ "${c}" == "${__ESTR}" ]] && command echo -e "${__ENT}" && break

    # Return Quit Action
    [[ "${c}" == "${__QUIT}" ]] && command echo -e "${__EXT}" && break

    # Append Character To Input Buffer
    buffer+=("$c")

    echo "-> ${#buffer[@]}"

    # Check Break Conditions
    if [[ ${#buffer[@]} -ge 3 ]]
    then
      local IFS=$''
      # Return Up Arrow Action
      [[ "${buffer[*]}" == "${_ESEQ}[A" ]] && command echo -e "${__UP}" && break

      # Return Down Arrow Action
      [[ "${buffer[*]}" == "${_ESEQ}[B" ]] && command echo -e "${__DN}" && break
      unset IFS
      # Reset Buffer
      buffer=()
    fi
  done
}

while [[ 1 ]]; do _read_input; done
