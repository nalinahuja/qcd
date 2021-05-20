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

# Release Files
readonly QCD_LICENSE=./LICENSE
readonly QCD_VERSION=./VERSION
readonly QCD_READ_ME=./README.md

# Terminal Profiles
readonly BASHRC=~/.bashrc
readonly BASHPR=~/.bash_profile

# End File Constants--------------------------------------------------------------------------------------------------------------------------------------------------

# Upgrade Status
declare UPGRADE_STATUS=${TRUE}

# Installation Status
declare INSTALL_STATUS=${FALSE}

# Installation Version
declare INSTALL_VERSION=$(command cat "${QCD_VERSION}")

# End Global Variables------------------------------------------------------------------------------------------------------------------------------------------------

# Prompt User For Installation Confirmation
command read -p "qcd: Confirm installation ${INSTALL_VERSION} [y/n]: " confirm

# Determine Action
if [[ "${confirm,}" == "${YES}" ]]
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
    if [[ ${INSTALL_STATUS} -eq ${FALSE} ]]
    then
      # Display Error Prompt
      command echo -e "→ No bash configurations found, aborting installation"

      # Terminate Program
      command exit 1
    fi

    # Update Upgrade Status
    UPGRADE_STATUS=${FALSE}
  fi

  # Create Program Folder
  command mkdir ${QCD_FOLD} 2> /dev/null

  # Install QCD Program Files
  command mv ${QCD_PROG} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_UTIL} ${QCD_FOLD} 2> /dev/null

  # Install QCD Release Files
  command mv ${QCD_LICENSE} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_VERSION} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_READ_ME} ${QCD_FOLD} 2> /dev/null

  # Determine Appropriate Prompt
  if [[ ${UPGRADE_STATUS} == ${TRUE} ]]
  then
    # Display Upgrade Prompt
    command echo -e "→ Upgraded QCD to ${INSTALL_VERSION}"
  else
    # Display Installation Prompt
    command echo -e "→ Installed QCD ${INSTALL_VERSION}"
  fi

  # Display Success Prompt
  command echo -e "\nPlease restart your terminal"
else
  # Display Abort Prompt
  command echo -e "→ Installation aborted"
fi

# End QCD Installation------------------------------------------------------------------------------------------------------------------------------------------------
