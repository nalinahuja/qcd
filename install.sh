#!/usr/bin/env bash

# Developed by Nalin Ahuja, nalinahuja22

# End Header----------------------------------------------------------------------------------------------------------------------------------------------------------

# Boolean Values
readonly TRUE=1 FALSE=0

# End Numerical Constants---------------------------------------------------------------------------------------------------------------------------------------------

# Embedded Strings
readonly YES="y"

# End String Constants------------------------------------------------------------------------------------------------------------------------------------------------

# Program Path
readonly QCD_FOLD=~/.qcd

# Program Files
readonly QCD_PROG=./qcd.sh
readonly QCD_UTIL=./lcs.pl
readonly QCD_LICE=./LICENSE
readonly QCD_READ=./README.md

# Terminal Profiles
readonly BASHRC=~/.bashrc
readonly BASHPR=~/.bash_profile

# End File Constants--------------------------------------------------------------------------------------------------------------------------------------------------

# Upgrade Status
declare UPGRADE_STATUS=${TRUE}

# Installation Status
declare INSTALL_STATUS=${FALSE}

# Installation Version
declare INSTALLATION_VERSION=$(command cat ${QCD_PROG} | command grep "QCD_RELEASE_VER" | command head -n1 | command awk -F '"' '{print $2}')

# End Global Variables------------------------------------------------------------------------------------------------------------------------------------------------

# Prompt User For Installation Confirmation
command read -p "qcd: Confirm installation v${INSTALLATION_VERSION} [y/n]: " confirm

# Determine Action
if [[ ${confirm//Y/${YES}} == ${YES} ]]
then
  # Verify Program Files
  if [[ ! -e "${QCD_PROG}" || ! -e "${QCD_LICE}" || ! -e "${QCD_READ}" ]]
  then
    # Display Prompt
    command echo -e "→ One or more source files are corrupted, aborting installation"

    # Terminate Program
    command exit 1
  fi

  # Add Command To Terminal Profile
  if [[ ! -d "${QCD_FOLD}" ]]
  then
    # Find ~/.bashrc
    if [[ -f "${BASHRC}" ]]
    then
      # Add Command To ~/.bashrc
      command echo -e "\n# QCD Utility Source\ncommand source ~/.qcd/qcd.sh\n" >> ${BASHRC}

      # Update Installation Status
      INSTALL_STATUS=${TRUE}
    fi

    # Find ~/.bash_profile
    if [[ -f "${BASHPR}" ]]
    then
      # Add Command To ~/.bash_profile
      command echo -e "\n# QCD Utility Source\ncommand source ~/.qcd/qcd.sh\n" >> ${BASHPR}

      # Update Installation Status
      INSTALL_STATUS=${TRUE}
    fi

    # Check Installation Status
    if [[ ${INSTALL_STATUS} == ${FALSE} ]]
    then
      # Display Error Prompt
      command echo -e "→ No bash configurations found, aborting installation"

      # Terminate Program
      command exit 1
    fi

    # Update Upgrade Status
    UPGRADE_STATUS=${FALSE}
  fi

  # Install QCD Program Files
  command mkdir ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_PROG} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_UTIL} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_LICE} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_READ} ${QCD_FOLD} 2> /dev/null

  # Determine Appropriate Prompt
  if [[ ${UPGRADE_STATUS} == ${TRUE} ]]
  then
    # Display Upgrade Prompt
    command echo -e "→ Upgraded QCD to ${INSTALLATION_VERSION}"
  else
    # Display Installation Prompt
    command echo -e "→ Installed QCD ${INSTALLATION_VERSION}"
  fi

  # Display Success Prompt
  command echo -e "\nPlease restart your terminal"
else
  # Display Abort Prompt
  command echo -e "→ Installation aborted"
fi

# End QCD Installation------------------------------------------------------------------------------------------------------------------------------------------------
