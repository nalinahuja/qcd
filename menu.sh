#!/usr/bin/env bash

N=$(command tput sgr0)
W=$(command tput setaf 0)$(command tput setab 7)

ESC=$(command printf "\033")

UP=1
DOWN=2
EXIT=3
ENTER=4

HIDE=1
SHOW=2

err_flag=false

function set_cursor_state() {
  if [[ ${1} -eq ${HIDE} ]]
  then
    command tput civis 2> /dev/null
  elif [[ ${1} -eq ${SHOW} ]]
  then
    command tput cnorm 2> /dev/null
  fi
}

function read_input() {
  # Initialize Key
  input=""

  while [[ 1 ]]
  do
    # Read User Input
    command read -s -n1 key 2> /dev/null
    input="${input}${key}"

    # Parse Input
    if [[ -z ${input} || ${input} == "q" || ${#input} -eq 3 ]]
    then
      break
    fi
  done

  # Determine Action
  if [[ ${input} == "$ESC[A" ]]
  then
    command echo -e "$UP"
  elif [[ ${input} == "$ESC[B" ]]
  then
    command echo -e "$DOWN"
  elif [[ ${input} == "q" ]]
  then
    command echo -e "$EXIT"
  fi
}

function exit_cleanly() {
  set_cursor_state ${SHOW}
  err_flag=true
}

function display_menu() {
  # Initialize Line Number
  local sel_line=0

  # Set Cursor To State On Exit
  command trap exit_cleanly ${SHOW} SIGINT &> /dev/null

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
        command printf "${W} ${opt} ${N}\n"
      else
        command printf " ${opt} \n"
      fi

      # Increment Option Index
      oi=$((${oi} + 1))
    done

    # Read User Input
    local key=$(read_input)

    if [[ ${err_flag} == true ]]
    then
      return -1
    fi

    # Determine Cursor Position
    if [[ ${key} -eq ${UP} ]]
    then
      # Go Up
      sel_line=$((${sel_line} - 1))
    elif [[ ${key} -eq ${DOWN} ]]
    then
      # Go Down
      sel_line=$((${sel_line} + 1))
    else
      if [[ ${key} -eq ${EXIT} ]]
      then
        sel_line=-1
      fi

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
  return ${sel_line}
}

display_menu "~/Documents/Lectures" "~/dev/leetcode" "~/dev/lightwave" "~/Documents/Lectures" "~/dev/leetcode" "~/dev/lightwave" "~/Documents/Lectures" "~/dev/leetcode" "~/dev/lightwave"

command echo -e "\nSelected option ${?}"
