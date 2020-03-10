#!/usr/bin/env bash

QCD_FOLD=~/.qcd
QCD_PROG=./qcd.sh
QCD_COMP=./comp.sh
QCD_LICE=./LICENSE
QCD_READ=./README.md
QCD_COMMAND="\nqcd() {\n  . ~/.qcd/qcd.sh \$1\n}"

read -p "Please Confirm Installation of QCD [y/n]: " confirm

if [ $confirm == y ] || [ $confirm == Y ]
then
  #Add Command To Terminal Profile
  if [[ -f ~/.zshrc ]]
  then
    echo -e $QCD_COMMAND >> ~/.zshrc
  elif [[ -f ~/.bashrc ]]
  then
    echo -e $QCD_COMMAND >> ~/.bashrc
  elif [[ -f ~/.bash_profile ]]
  then
    echo -e $QCD_COMMAND >> ~/.bash_profile
  fi

  echo -e "→ Installed QCD Command To Terminal Config"

  # Store Program Files
  command mkdir $QCD_FOLD
  command mv $QCD_PROG $QCD_FOLD
  command mv $QCD_COMP $QCD_FOLD
  command mv $QCD_LICE $QCD_FOLD
  command mv $QCD_READ $QCD_FOLD

  echo -e "→ Installed QCD In ~/.qcd"

  # Clean Installer
  installer_path=$(pwd)
  command rm -rf $installer_path

  # End Installation
  echo -e "\nPlease Restart Your Terminal To Use QCD"
elif [ $confirm == n ] || [ $confirm == N ]
then
  echo -e "\nQCD Installation Aborted!"
else
  echo -e "\nInvalid Flag, Installation Aborted!"
fi
