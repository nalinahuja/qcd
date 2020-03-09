#!/usr/bin/env bash

QCD_FOLD=~/.qcd
QCD_PROG=./qcd.sh
QCD_LICE=./LICENSE
QCD_READ=./README.md
QCD_COMMAND="\nqcd() {\n if [[ \$1 = '-reset' ]]\n then\n   > ~/.qcd/qcd_store\n else\n   . ~/.qcd/qcd.sh \$1\n fi\n}"

read -p "Please Confirm Installation of QCD [y/n]: " confirm

if [ $confirm == y ] || [ $confirm == Y ]
then
  #Add Command To Bash Profile
  if [[ -f ~/.bashrc ]]
  then
    echo -e $QCD_COMMAND >> ~/.bashrc
    source ~/.bashrc
  elif [[ -f ~/.bash_profile ]]
  then
    echo -e $QCD_COMMAND >> ~/.bash_profile
    source ~/.bash_profile
  fi

  echo -e "→ Installed QCD Command To Bash Config"

  # Store Program Files
  installer_path=$(pwd)

  command mkdir $QCD_FOLD
  command mv $QCD_PROG $QCD_FOLD
  command mv $QCD_LICE $QCD_FOLD
  command mv $QCD_READ $QCD_FOLD

  echo -e "→ Installed QCD In ~/.qcd"

  # Clean Installer
  command rm -rf $installer_path

  # End Installation
  echo -e "\nPlease Either Restart The Terminal Or Run Source To Use QCD"
elif [ $confirm == n ] || [ $confirm == N ]
then
  echo -e "\nQCD Installation Aborted!"
else
  echo -e "\nInvalid Flag, Installation Aborted!"
fi
