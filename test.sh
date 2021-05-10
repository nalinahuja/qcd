regex="\.a.*r.*c.*h.*i.*v.*e.*"

command awk -F ':' -v REGEX="${regex}" '{if ($1 ~ REGEX) {print $2}}' ~/.qcd/store 2> /dev/null
