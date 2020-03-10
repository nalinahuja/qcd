#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_FOLD=~/.qcd
QCD_PROG=./qcd.sh
QCD_COMP=./comp.sh
QCD_LICE=./LICENSE
QCD_READ=./README.md
QCD_STORE=~/.qcd/store
QCD_COMMAND="\nqcd() {\n  . ~/.qcd/qcd.sh \$1\n  source %s\n}\n\nsource ~/.qcd/comp.sh"

read -p "Please Confirm Installation of QCD [y/n]: " confirm

if [ $confirm == y ] || [ $confirm == Y ]
then
  #Add Command To Terminal Profile
  if [[ -f ~/.zshrc ]]
  then
    printf $QCD_COMMAND "~/.zshrc" >> ~/.zshrc
    source ~/.zshrc
  elif [[ -f ~/.bashrc ]]
  then
    printf $QCD_COMMAND "~/.bashrc" >> ~/.bashrc
    source ~/.bashrc
  elif [[ -f ~/.bash_profile ]]
  then
    printf $QCD_COMMAND "~/.bash_profile" >> ~/.bash_profile
    source ~/.bash_profile
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

  # Create Empty File
  touch $QCD_STORE

  # Update Terminal Config
  echo -e "\nQCD Has Successfully Installed"
elif [ $confirm == n ] || [ $confirm == N ]
then
  echo -e "\nQCD Installation Aborted!"
else
  echo -e "\nInvalid Flag, Installation Aborted!"
fi
