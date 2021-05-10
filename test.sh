curr_arg=".arc"
sym_link=".arc"
__CWD="."

if [[ ${curr_arg:0:1} == ${__CWD} && ${sym_link:0:1} == ${__CWD} || ! ${curr_arg:0:1} == ${__CWD} && ! ${sym_link:0:1} == ${__CWD} ]]
then
  echo bruh
fi
