#!/usr/bin/env bash

# Developed by Nalin Ahuja, nalinahuja22

# End Header----------------------------------------------------------------------------------------------------------------------------------------------------------

# Program Path
readonly QCD_FOLD=~/.qcd

# Program Files
readonly QCD_SH=./qcd.sh
readonly QCD_PL=./rank.pl

# Release Files
readonly QCD_LICENSE=./LICENSE
readonly QCD_VERSION=./VERSION
readonly QCD_READ_ME=./README.md

# Bash Configurations
readonly BASH_CONFIGS=(~/.bashrc ~/.bash_profile)

# Verify Installation Files
if [[ ! -e "${QCD_SH}" || ! -e "${QCD_PL}" || ! -e "${QCD_LICENSE}" || ! -e "${QCD_VERSION}" || ! -e "${QCD_READ_ME}" ]]
then
  # Display Prompt
  command echo -e "qcd: One or more installation files are missing or corrupted, aborting installation"

  # Terminate Program
  command exit 1
fi

# End File Constants--------------------------------------------------------------------------------------------------------------------------------------------------

# Boolean Constants
readonly TRUE=1 FALSE=0

# Embedded Strings
readonly NL="\n" YES="y" ESEQ=$(command printf "\033") &> /dev/null

# Text Formatting Strings
readonly B=$(command printf "${ESEQ}[1m") N=$(command printf "${ESEQ}(B${ESEQ}[m") &> /dev/null

# End Embedded Constants----------------------------------------------------------------------------------------------------------------------------------------------

# Update Status
declare UPDATE_STATUS=${TRUE}

# Installation Status
declare INSTALL_STATUS=${FALSE}

# Installation Version
declare INSTALL_VERSION=$(command cat ${QCD_VERSION} 2> /dev/null)

# End Global Variables------------------------------------------------------------------------------------------------------------------------------------------------

# Prompt User For Program Installation Confirmation
command read -p "qcd: Confirm program installation ${B}${INSTALL_VERSION}${N} [y/n]: " confirm

# Determine Action
if [[ "${confirm,}" == "${YES}" ]]
then
  # Add Command To Bash Configurations
  if [[ ! -d "${QCD_FOLD}" ]]
  then
    # Iterate Over Bash Configurations
    for BASH_CONFIG in ${BASH_CONFIGS[@]}; do
      # Verfiy Bash Configuration Exists
      if [[ -f "${BASH_CONFIG}" ]]
      then
        # Add Command To Bash Configuration
        command echo -e "${NL}# QCD Utility Source${NL}command source ~/.qcd/qcd.sh${NL}" >> ${BASH_CONFIG}

        # Update Installation Status
        INSTALL_STATUS=${TRUE}
      fi
    done

    # Verify Installation Status
    if [[ ${INSTALL_STATUS} -eq ${FALSE} ]]
    then
      # Display Error Prompt
      command echo -e "→ No bash configurations found, aborting installation"

      # Terminate Program
      command exit 1
    fi

    # Change Update Status
    UPDATE_STATUS=${FALSE}
  fi

  # Determine Appropriate Action
  if [[ ${UPDATE_STATUS} -eq ${TRUE} ]]
  then
    # Uninstall Old Program Files
    command rm ${QCD_FOLD}/*.sh ${QCD_FOLD}/*.pl
  else
    # Create Program Folder
    command mkdir ${QCD_FOLD} 2> /dev/null
  fi

  # Install QCD Program Files
  command mv ${QCD_SH} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_PL} ${QCD_FOLD} 2> /dev/null

  # Install QCD Release Files
  command mv ${QCD_LICENSE} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_VERSION} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_READ_ME} ${QCD_FOLD} 2> /dev/null

  # Determine Appropriate Prompt
  if [[ ${UPDATE_STATUS} -eq ${TRUE} ]]
  then
    # Display Update Prompt
    command echo -e "→ Upgraded QCD to ${B}${INSTALL_VERSION}${N}"
  else
    # Display Installation Prompt
    command echo -e "→ Installed QCD ${B}${INSTALL_VERSION}${N}"
  fi

  # Display Success Prompt
  command echo -e "${NL}Please restart your terminal"
else
  # Display Abort Prompt
  command echo -e "→ Installation aborted"
fi

# End QCD Installation Script-----------------------------------------------------------------------------------------------------------------------------------------
