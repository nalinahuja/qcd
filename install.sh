#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_FOLD=~/.qcd
QCD_PROG=./qcd.sh
QCD_COMP=./comp.sh
QCD_LICE=./LICENSE
QCD_READ=./README.md
QCD_STOR=~/.qcd/store

read -p "Please Confirm Installation of QCD [y/n]: " confirm

if [ $confirm == y ] || [ $confirm == Y ]
then
  if [[ -f ~/.bashrc ]]
  then
    echo -e "\nqcd() {\n  . ~/.qcd/qcd.sh \$1\n  source  ~/.bashrc\n}\n\nsource ~/.qcd/comp.sh" >> ~/.bashrc
  elif [[ -f ~/.bash_profile ]]
  then
    echo -e "\nqcd() {\n  . ~/.qcd/qcd.sh \$1\n  source ~/.bash_profile\n}\n\nsource ~/.qcd/comp.sh" >> ~/.bash_profile
  fi

  echo -e "→ Installed QCD Command To Terminal Config"

  command mkdir $QCD_FOLD
  command mv $QCD_PROG $QCD_FOLD
  command mv $QCD_COMP $QCD_FOLD
  command mv $QCD_LICE $QCD_FOLD
  command mv $QCD_READ $QCD_FOLD

  echo -e "→ Installed QCD In ~/.qcd"

  touch $QCD_STOR

  echo -e "\nQCD Successfully Installed, Please Restart Your Terminal!"
elif [ $confirm == n ] || [ $confirm == N ]
then
  echo -e "\nQCD Installation Aborted!"
else
  echo -e "\nInvalid Flag, Installation Aborted!"
fi
