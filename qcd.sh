#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

# qcd space delim handling
# qcd cleanup -c
# qcd forget -f

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp

b=$(tput bold)
n=$(tput sgr0)

# End Global Variables----------------------------------------------------------------------------------------------------------------------------------------------

function format_dir() {
  # Format Directory From Home
  command echo -e "~$(echo -e $1 | cut -c $((${#HOME} + 1))-${#1})"
}

function add_directory() {
  # Store Current Directory Information
  local dir="$(pwd)/"
  local ept=$(basename $dir)

  # Append To QCD Store If Unique
  if [[ ! "$dir" = "$HOME/" && -z $(egrep -s -x ".* $dir" $QCD_STORE) ]]
  then
    command printf "%s %s\n" $ept $dir >> $QCD_STORE
  fi
}

function remove_directory() {
  # Remove Directory By Line Number
  local del_line=$(egrep -s -n "$1" $QCD_STORE | cut -d ':' -f1)
  command sed "${del_line}d" $QCD_STORE > $QCD_TEMP
  command mv $QCD_TEMP $QCD_STORE
}

# End Helper Function-----------------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Store First Argument
  indicated_dir="$1"

  # Set To Home Directory If Empty
  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Create QCD Store
  if [[ ! -f $QCD_STORE ]]
  then
    command touch $QCD_STORE
  fi

  # Determine If Path Is Linked
  if [[ -e $indicated_dir ]]
  then
    # Change To Unlinked Directory
    command cd $indicated_dir

    # Store Complete Path And Endpoint
    add_directory
  else
    # Get Path Prefix and Suffix
    local prefix=$(echo -e "$indicated_dir" | cut -d '/' -f1)
    local suffix=""

    # Get Path Suffix If Non-Empty
    if [[ "$indicated_dir" == *\/* ]]
    then
      suffix=${indicated_dir:${#prefix} + 1}
    fi

    # Check For File Link In Store File
    local res=$(egrep -s -x "$prefix.*" $QCD_STORE)
    local res_cnt=$(echo "$res" | wc -l)

    # Check Result Count
    if [[ $res_cnt -gt 1 ]]
    then
      # Prompt User
      command echo -e "qcd: Multiple paths linked to ${b}$prefix${n}"

      # Store Paths In Order Of Absolute Path
      local paths=$(echo -e "$res" | cut -d ' ' -f2 | sort)

      # Display Options
      local cnt=1
      for path in $paths
      do
        path=$(format_dir $path)
        command printf "(%d) %s\n" $cnt $path
        cnt=$((cnt + 1))
      done

      # Format Selected Endpoint
      command read -p "Endpoint: " ept

      # Error Check Bounds
      if [[ $ept -lt 1 ]]
      then
        ept=1
      elif [[ $ept -gt $res_cnt ]]
      then
        ept=$res_cnt
      fi

      # Format Endpoint
      res=$(echo $paths | cut -d ' ' -f$ept)
    else
      # Format Endpoint
      res=$(echo $res | cut -d ' ' -f2)
    fi

    # Error Check Result
    if [[ -z $res ]]
    then
      # Prompt User
      command echo -e "qcd: Cannot link keyword to directory"
    elif [[ ! -e $res ]]
    then
      # Prompt User Of Error
      if [[ $res_cnt -gt 1 ]]; then echo; fi
      command echo -e "qcd: $(format_dir $res): Directory does not exist"

      # Remove Invalid Path From QCD Store
      remove_directory $res
    else
      # Change Directory To Linked Path
      command cd $res

      # Check If Suffix Exists And Valid
      if [[ ! -z $suffix && -e $suffix ]]
      then
        # Change Directory To Subdirectory
        command cd $suffix

        # Store Complete Path And Endpoint
        add_directory
      fi
    fi
  fi
}

# End QCD Function---------------------------------------------------------------------------------------------------------------------------------------------------

function _qcd_comp() {
  # Store Current Commandline Argument
  CURR_ARG=${COMP_WORDS[1]}
  LINK_ARG=${CURR_ARG:0:$(echo "${COMP_WORDS[1]}" | awk -F "/" '{print length($0)-length($NF)}')}

  # Initialize Word List
  WORD_LIST=""

  # Path Completion
  if [[ "$LINK_ARG" == *\/* ]]
  then
    if [[ ! -e $CURR_ARG ]]
    then
      RES_DIR="$(cat $QCD_STORE | awk '{print $2}' | sort | egrep -s -m1 "$LINK_ARG")"
    else
      RES_DIR="$CURR_ARG"
    fi

    SUB_DIRS=$(command ls -l $RES_DIR | egrep -s ^d | awk '{print $9}')

    # Check RES_DIR
    if [[ ! -z $RES_DIR ]]
    then
      # Generate WORD_LIST
      for SUB_DIR in $SUB_DIRS
      do
        # Create Temp Sub-Dir
        WORD="$LINK_ARG$SUB_DIR"

        # Append Completion Slash
        if [[ ! -e $WORD ]]
        then
          WORD_LIST="${WORD_LIST} $WORD/"
        else
          WORD_LIST="${WORD_LIST} $WORD"
        fi
      done

      COMPREPLY=($(compgen -W "$WORD_LIST" "${COMP_WORDS[1]}"))
    fi
  else
    # Endpoint Completion
    QUICK_DIRS=$(cat $QCD_STORE | awk '{printf $1 "/:" $2 "\n"}' | sort)

    # Remove Duplicate Dirs
    for DIR in $QUICK_DIRS
    do
      local link=$(echo -e $DIR | cut -d ':' -f1)
      local path=$(echo -e $DIR | cut -d ':' -f2)
      local pwd=$(pwd)

      if [[ ! -e $link && ! "$path" = "$pwd" ]]
      then
        WORD_LIST="${WORD_LIST} $link"
      fi
    done

    COMPREPLY=($(compgen -W "$WORD_LIST" "${COMP_WORDS[1]}"))
  fi
}

# End QCD Completion Function---------------------------------------------------------------------------------------------------------------------------------------

# Call QCD Function
qcd $1

# Update Completion List
if [[ -e $QCD_STORE ]]
then
  command complete -o nospace -o dirnames -A directory -F _qcd_comp -X ".*" qcd
fi

# End Main----------------------------------------------------------------------------------------------------------------------------------------------------------
