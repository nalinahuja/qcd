#!/usr/bin/env bash

# Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Boolean Values
declare -r TRUE=1 FALSE=0

# End Numerical Constants--------------------------------------------------------------------------------------------------------------------------------------------

# Embedded Strings
declare -r YES="y"

# End String Constants-----------------------------------------------------------------------------------------------------------------------------------------------

# Program Path
declare -r QCD_FOLD=~/.qcd

# Program Files
declare -r QCD_HELP=./help
declare -r QCD_PROG=./qcd.sh
declare -r QCD_LICE=./LICENSE
declare -r QCD_READ=./README.md

# Terminal Profiles
declare -r BASHRC=~/.bashrc
declare -r BASHPR=~/.bash_profile

# End File Constants-------------------------------------------------------------------------------------------------------------------------------------------------

# Upgrade Status
declare -i upgrade_status=${TRUE}

# Installation Status
declare -i install_status=${FALSE}

# Installation Version
declare install_version

# End Global Variables-----------------------------------------------------------------------------------------------------------------------------------------------

# Prompt User For Installation Confirmation
command read -p "qcd: Confirm installation [y/n]: " confirm

# Determine Action
if [[ ${confirm//Y/${YES}} == ${YES} ]]
then
  # Verify Program Files
  if [[ ! -e ${QCD_HELP} || ! -e ${QCD_PROG} || ! -e ${QCD_LICE} || ! -e ${QCD_READ} ]]
  then
    # Display Prompt
    command echo -e "→ One or more program files are corrupted, aborting installation"

    # Terminate Program
    command exit 1
  fi

  install_version=$(command cat ${QCD_HELP} | command head -n1 | command awk '{print $4}')

  # Add Command To Terminal Profile
  if [[ ! -d ${QCD_FOLD} ]]
  then
    # Find ~/.bashrc
    if [[ -f ${BASHRC} ]]
    then
      # Add Command To ~/.bashrc
      command echo -e "\n# QCD Utility Source\ncommand source ~/.qcd/qcd.sh\n" >> ${BASHRC}

      # Update Installation Status
      install_status=${TRUE}
    fi

    # Find ~/.bash_profile
    if [[ -f ${BASHPR} ]]
    then
      # Add Command To ~/.bash_profile
      command echo -e "\n# QCD Utility Source\ncommand source ~/.qcd/qcd.sh\n" >> ${BASHPR}

      # Update Installation Status
      install_status=${TRUE}
    fi

    # Check Installation Status
    if [[ ${install_status} == ${FALSE} ]]
    then
      # Display Error Prompt
      command echo -e "→ No bash configurations found, aborting installation"

      # Terminate Program
      command exit 1
    fi

    # Update Upgrade Status
    upgrade_status=${FALSE}
  fi

  # Install QCD Program Files
  command mkdir ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_PROG} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_HELP} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_LICE} ${QCD_FOLD} 2> /dev/null
  command mv ${QCD_READ} ${QCD_FOLD} 2> /dev/null

  # Determine Appropriate Prompt
  if [[ ${upgrade_status} == ${TRUE} ]]
  then
    # Display Upgrade Prompt
    command echo -e "→ Upgraded QCD to ${install_version}"
  else
    # Display Installation Prompt
    command echo -e "→ Installed QCD ${install_version}"
  fi

  # Display Success Prompt
  command echo -e "\nPlease restart your terminal"
else
  # Display Abort Prompt
  command echo -e "→ Installation aborted"
fi

# End QCD Installation-----------------------------------------------------------------------------------------------------------------------------------------------
