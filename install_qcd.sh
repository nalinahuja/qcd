#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_FOLD=~/.qcd
QCD_PROG=./qcd.sh
QCD_COMP=./comp.sh
QCD_LICE=./LICENSE
QCD_READ=./README.md

read -p "Please Confirm Installation of QCD [y/n]: " confirm

if [ $confirm == y ] || [ $confirm == Y ]
then
  if [[ ! -e $QCD_FOLD ]]
  then
    if [[ -f ~/.bashrc ]]
    then
      echo -e "# qcd Function (qcd [PATH] [OPTIONS])\n\nsource ~/.qcd/qcd.sh\nsource ~/.qcd/comp.sh\nqcd -c\n" >> ~/.bashrc
    elif [[ -f ~/.bash_profile ]]
    then
      echo -e "# qcd Function (qcd [PATH] [OPTIONS])\n\nsource ~/.qcd/qcd.sh\nsource ~/.qcd/comp.sh\nqcd -c\n" >> ~/.bash_profile
    else
      echo -e "ERROR: Failed to Install Command To Terminal Profile. Installation Aborted!"
      exit 1
    fi

    echo -e "→ Installed QCD Command To Terminal Config"
  fi

  command mkdir $QCD_FOLD 2> /dev/null
  command mv $QCD_PROG $QCD_FOLD
  command mv $QCD_COMP $QCD_FOLD
  command mv $QCD_LICE $QCD_FOLD
  command mv $QCD_READ $QCD_FOLD

  echo -e "→ Installed QCD In ~/.qcd"

  echo -e "\nQCD Successfully Installed, Please Restart Your Terminal!"
elif [ $confirm == n ] || [ $confirm == N ]
then
  echo -e "\nQCD Installation Aborted!"
else
  echo -e "\nERROR: Invalid Flag, Installation Aborted!"
fi
