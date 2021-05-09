#!/usr/bin/env bash

# PARAMS=""
#
# while (( "$#" )); do
#
#   echo $#
#   case "$1" in
#     -a|--my-boolean-flag)
#       MY_FLAG=0
#       echo bruh
#       shift
#       ;;
#     -b|--my-flag-with-argument)
#       if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
#         MY_FLAG_ARG=$2
#
#         echo $MY_FLAG_ARG
#         shift 2
#       else
#         echo "Error: Argument for $1 is missing" >&2
#         exit 1
#       fi
#       ;;
#     -*|--*=) # unsupported flags
#       echo "Error: Unsupported flag $1" >&2
#       exit 1
#       ;;
#     *) # preserve positional arguments
#       PARAMS="$PARAMS $1"
#       shift
#       ;;
#   esac
# done
#
# # set positional arguments in their proper place
# eval set -- "$PARAMS"
#
# echo SF $PARAMS

for i in {1..100}; do
  command egrep -s -x ".*:/Users/apple/dev/qcd/" ~/.qcd/store &> /dev/null
  command egrep -s -x "qcd:/Users/apple/dev/qcd/" ~/.qcd/store &> /dev/null
done

# for i in {1..100}; do
#   awk -F ':' -v KEY="/Users/apple/dev/qcd/" '$2 == KEY {print $1}' ~/.qcd/store &> /dev/null
#   awk -F ':' -v KEY="qcd:/Users/apple/dev/qcd/" '$0 == KEY {print $1}' ~/.qcd/store &> /dev/null
# done
