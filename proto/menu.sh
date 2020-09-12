#!/usr/bin/env bash

N=$(command tput sgr0)
W=$(command tput setaf 0)$(command tput setab 7)

ESC=$(command printf "\033")

function read_input() {
  command read -s -n3 key 2> /dev/null

  if [[ ${key} == "$ESC[A" ]]; then echo "up"; fi
  if [[ ${key} == "$ESC[B" ]]; then echo "down"; fi
  if [[ -z ${key} || ${key} == "q" ]]; then echo "empty"; fi
}

function display_menu() {

  tput civis
  local curr_line=0

  while true
  do
    local ai=0
    for arg in "$@"
    do
      if [[ $ai -eq $curr_line ]]
      then
        printf "${W}${arg}${N}  \n"
      else
        printf "${arg}  \n"
      fi

      ai=$((ai + 1))
    done

    in=$(read_input)

    if [[ $in == "up" ]]
    then
      curr_line=$(($curr_line - 1))
    elif [[ $in == "down" ]]
    then
      curr_line=$(($curr_line + 1))
    else
      tput cnorm
      return 256;
    fi

    echo $curr_line > log

    if [[ $curr_line -eq 3 ]]
    then
      curr_line=0
    elif [[ $curr_line -lt 0 ]]
    then
      curr_line=$(($# - 1))
    fi

    command printf "$ESC[3A"
  done

  return $curr_line
}

function norm_input() {
  tput cnorm
}

command trap norm_input EXIT &> /dev/null

display_menu "~/Documents/Lectures" "~/dev/leetcode" "~/dev/lightwave"

command echo -e "Selected option: ${?}"
