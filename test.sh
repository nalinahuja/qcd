#!/usr/bin/env bash

# function program() {
#   command echo -e "${@}" | command cut -d '/' -f1
# }
#
# function param() {
#   # Store Argument Directory
#   local dir="${@%/}/"
#
#   # Get Argument Directory Components
#   local pfx="${dir#*/*}"
#
#   # Determine Return
#   if [[ -z ${pfx} ]]
#   then
#     # Return Full Argument Directory
#     command echo -e "${dir%/}"
#   else
#     # Determine Substring Bounds
#     local si=0 ei=""
#
#     # Return Argument Directory Substring
#     command echo -e "${dir:0:$((${#dir} - ${#pfx} - 1))}"
#   fi
# }
#
# ctl=0 my=0
#
# test="asdf/"
# ctl=$(program "$test")
# my=$(param "$test")
# printf "${test} -> ${ctl} == ${my}\n"
#
# test="asdf/qwer"
# ctl=$(program "$test")
# my=$(param "$test")
# printf "${test} -> ${ctl} == ${my}\n"
#
# test="asdf/qwer/1234/"
# ctl=$(program "$test")
# my=$(param "$test")
# printf "${test} -> ${ctl} == ${my}\n"
#
# test="asdf"
# ctl=$(program "$test")
# my=$(param "$test")
# printf "${test} -> ${ctl} == ${my}\n"
#
# test="bruh moment/asdf/qwer"
# ctl=$(program "$test")
# my=$(param "$test")
# printf "${test} -> ${ctl} == ${my}\n"

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------

# function program() {
#   # Store Argument Directory
#   basename "${@}"
# }
#
# function param() {
#   # Store Argument Directory
#   local dir="${@%/}/"
#
#   # Get Prefix String
#   local pfx="${dir%/*/}"
#
#   # Get Suffix String
#   sfx="${dir:$((${#pfx} + 1))}"
#
#   if [[ -z ${sfx} ]]
#   then
#     command echo -e "${pfx%/}"
#   else
#     # Return Directory Name
#     command echo -e "${sfx%/}"
#   fi
# }
#
# ctl=0 my=0
#
# test=asdf
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test=/Users/apple/qwer
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test=/Users/apple
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test=asdf/
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test=asdf/qwer
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test="asdf/bruh moment"
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test=asdf/qwer/1234
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"
#
# test=asdf/qwer/1234/
#
# ctl=$(program "$test")
# my=$(param "$test")
#
# printf "${test} -> ${ctl} == ${my}\n"

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------

curr_arg="asdf"

# Obtain Symbolic Link
link_arg=$(command echo -e "${curr_arg}" | command cut -d '/' -f1)

# Obtain Trailing Subdirectory Path
trail_arg=$(command echo -e "${curr_arg}" | command awk -F '/' '{print $NF}')

# Obtain Leading Subdirectory Path
subs_len=$(command echo -e "${curr_arg}" | command awk -F '/' '{print length($0)-length($NF)}')
subs_arg=${curr_arg:$((${#link_arg} + 1)):$((${subs_len} - ${#link_arg} - 1))}

echo
echo link $link_arg
echo trail $trail_arg
echo sub $subs_arg
