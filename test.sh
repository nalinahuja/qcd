# 3.505s with manual path splitting

function _get_pwd() {
  # Store Current Working Directory
  local pwd=$(command pwd)

  # Return Current Working Directory
  command echo -e "${pwd}${__FLSH}"
}

regex="d.*"

pathv=$(command egrep -i -s -x "${regex}:.*" ~/.qcd/store 2> /dev/null)

for link in ${pathv[@]}
do
  echo "$link"
done

# Initialize Matched Path
mpath=${__ESTR}

# Store Current Directory
pwd=$(_get_pwd)

# Initialize Filtered Paths
fpaths=()

IFS=$'\n'

fpaths=($(command echo -e "${pathv[@]}" | command awk -F ':' '{print $2}'))

for link in ${fpaths[@]}
do
  echo "$link"
done
