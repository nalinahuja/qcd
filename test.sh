#!/usr/bin/env bash

# function program() {
#   echo -ne "program: "
#   command echo -e "${@}" | command cut -d '/' -f1
# }
#
# function param() {
#   echo -ne "param: "
#   first=${@#*/}
#   echo $first
# }
#
# curr_arg=asdf/
#
# program $curr_arg
# param $curr_arg
#
# curr_arg=asdf/qwer
#
# program $curr_arg
# param $curr_arg
#
# curr_arg=asdf/qwer/1234/
#
# program $curr_arg
# param $curr_arg

function program() {
  # Store Argument Directory
  basename "${@}"
}

function param() {
  # Store Argument Directory
  local dir="${@%/}/"

  # Get Prefix String
  local pfx="${dir%/*/}"

  # Get Suffix String
  local sfx="${dir:$((${#pfx} + 1))}"

  if [[ -z ${sfx} ]]
  then
    command echo -e "${pfx%/}"
  else
    # Return Directory Name
    command echo -e "${sfx%/}"
  fi
}

ctl=0 my=0

test=asdf

ctl=$(program "$test")
my=$(param "$test")

printf "${test} -> ${ctl} == ${my}\n"

test=asdf/

ctl=$(program "$test")
my=$(param "$test")

printf "${test} -> ${ctl} == ${my}\n"

test=asdf/qwer

ctl=$(program "$test")
my=$(param "$test")

printf "${test} -> ${ctl} == ${my}\n"

test="asdf/bruh moment"

ctl=$(program "$test")
my=$(param "$test")

printf "${test} -> ${ctl} == ${my}\n"

test=asdf/qwer/1234

ctl=$(program "$test")
my=$(param "$test")

printf "${test} -> ${ctl} == ${my}\n"

test=asdf/qwer/1234/

ctl=$(program "$test")
my=$(param "$test")

printf "${test} -> ${ctl} == ${my}\n"
