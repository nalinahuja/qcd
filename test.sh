function _get_pwd() {
  # Store Current Working Directory
  local pwd=$(command pwd)

  # Return Current Working Directory
  command echo -e "${pwd}${__FLSH}"
}

function _split_path() {
  # Return Path Of Symbolic Link
  command echo -e "${@#*:}"
}

regex="d.*"

pathv=($(command egrep -i -s -x "${regex}:.*" ~/.qcd/store 2> /dev/null))

echo -e "${pathv[@]}" |
    while read path; do
        path=$(_split_path "$path")
        echo $path
        [[ -d "${path}qcd" ]] && echo "${path}qcd";
    done

# for link in ${pathv[@]}
# do
#   echo "$link"
# done

echo $pathv

exit

echo

sub_dir="qcd"

# Store Current Directory
pwd=$(_get_pwd)

# Initialize Filtered Paths
fpaths=()

IFS=$'\n'

fpaths=($(command echo -e "${pathv[@]}" | command awk -F ':' -v SUBDIR="${sub_dir}" '{ VAR=$2SUBDIR; if (system("[[ -d "VAR" ]]") == 1) {print $2}}'))

echo "output:"
for link in ${fpaths[@]}
do
  echo "$link"
done
