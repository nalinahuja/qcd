#!/usr/bin/env bash

# Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Return Values
declare -r NFD=127

# Boolean Values
declare -r TRUE=1 FALSE=0

# Embedded Values
declare TIMEOUT=10 COLNUM=256

# End Numerical Constants--------------------------------------------------------------------------------------------------------------------------------------------

# Embedded Strings
declare -r YES="y" KESC=$(command printf "\033")

# End String Constants------------------------------------------------------------------------------------------------------------------------------------------------

# Program Path
declare -r QCD_FOLD=~/.qcd

# Program Files
declare -r QCD_HELP=./help
declare -r QCD_PROG=./qcd.sh
declare -r QCD_LICE=./LICENSE
declare -r QCD_READ=./README.md

# Release Files
declare -r QCD_RELEASE=${QCD_FOLD}/release.zip
declare -r QCD_INSTALL=${QCD_FOLD}/install.sh

# Terminal Profiles
declare -r BASHRC=~/.bashrc
declare -r BASHPR=~/.bash_profile

# Release Link
declare -r QCD_RELEASE_URL="https://api.github.com/repos/nalinahuja22/qcd/releases/latest"

# End File Constants-------------------------------------------------------------------------------------------------------------------------------------------------

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

# End User Inferface Functions---------------------------------------------------------------------------------------------------------------------------------------


# End Global Variables-----------------------------------------------------------------------------------------------------------------------------------------------

# Prompt User For Installation Confirmation
command read -p "qcd: Confirm installation [y/n]: " confirm

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
  command echo -en "→ Downloading release"

  # Determine Download URL
  local download_url=$(command curl --connect-timeout ${TIMEOUT} -sL ${QCD_RELEASE_URL} 2> /dev/null | command egrep -s -o "https.*zipball.*" 2> /dev/null)

  # Error Check Download URL
  if [[ ${?} -ne ${OK} || -z ${download_url} ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to resolve download link for release"

    # Terminate Program
    return ${ERR}
  fi

  # Download Release Contents
  command curl --connect-timeout ${TIMEOUT} -sL "${download_url/\",/}" > ${QCD_RELEASE}

  # Error Check Release Contents
  if [[ ${?} -ne ${OK} || ! -f ${QCD_RELEASE} ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to download release"

    # Terminate Program
    return ${ERR}
  fi

  # Display Prompt
  command echo -en "\r→ Installing release  "

  # Extract And Install Program Files
  command unzip -o -j ${QCD_RELEASE} -d ${QCD_FOLD} &> /dev/null

  # Error Check Installation
  if [[ ${?} -ne ${OK} ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to install release"

    # Terminate Program
    return ${ERR}
  fi

  # Cleanup Installation
  command rm ${QCD_RELEASE} ${QCD_INSTALL} 2> /dev/null

  # Clear All Outputs
  _clear_output 2

  # Display Prompt
  command echo -e "qcd: Installed QCD $(command cat ${QCD_HELP} | command head -n1 | command awk '{print $4}'), please restart your terminal."
else
  # Display Abort Prompt
  command echo -e "→ QCD installation aborted"
fi

# End QCD Installation-----------------------------------------------------------------------------------------------------------------------------------------------
