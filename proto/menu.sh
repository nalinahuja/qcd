#!/usr/bin/env bash

N=$(command tput sgr0)
W=$(command tput setaf 0)$(command tput setab 7)

ESC=$(command printf "\033")

UP=1
DN=2
EN=3

HIDE=1
SHOW=2

function set_cursor_state() {
  if [[ ${1} == ${HIDE} ]]
  then
    command tput civis
  elif [[ ${1} == ${SHOW} ]]
  then
    command tput cnorm
  fi
}

function read_input() {
  # Read User Input
  command read -s -n3 key 2> /dev/null

  # Determine Action
  if [[ ${key} == "$ESC[A" ]]
  then
    command echo -e "$UP"
  elif [[ ${key} == "$ESC[B" ]]
  then
    command echo -e "$DN"
  elif [[ -z ${key} ]]
  then
    command echo -e "$EN"
  fi
}

function display_menu() {
  # Initialize Line Number
  local sel_line=0

  # Hide Cursor
  set_cursor_state ${HIDE}

  # Begin Selection Loop
  while true
  do
    # Intiailize Option Index
    local oi=0

    # Print All Options
    for opt in "${@}"
    do
      if [[ ${oi} -eq ${sel_line} ]]
      then
        command printf " ${W}${opt}${N} \n"
      else
        command printf " ${opt} \n"
      fi

      # Increment Option Index
      oi=$((${oi} + 1))
    done

    # Read User Input
    local key=$(read_input)

    # Determine Cursor Position
    if [[ ${key} == ${UP} ]]
    then
      # Go Up
      sel_line=$((${sel_line} - 1))
    elif [[ ${key} == $DN ]]
    then
      # Go Down
      sel_line=$((${sel_line} + 1))
    else
      # Break Loop
      break
    fi

    # Range Check Cursor Position
    if [[ ${sel_line} -eq $# ]]
    then
      sel_line=0
    elif [[ ${sel_line} -lt 0 ]]
    then
      sel_line=$(($# - 1))
    fi

    # Clear Previous N Lines
    command printf "${ESC}[$#A"
  done

  # Hide Cursor
  set_cursor_state ${SHOW}

  # Return Selected Line
  command echo -e  "${sel_line}"
}

opt=$(display_menu "~/Documents/Lectures" "~/dev/leetcode" "~/dev/lightwave")

command echo -e "\nSelected option ${opt}"
