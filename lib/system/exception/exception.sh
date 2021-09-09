
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
#---------------------------------------

throw() {
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: e="Mesage" throw ['...']
  echo -en "Exception: $*\n" 1>&2
  for (( i=0; i<${#BASH_SOURCE[@]}; i++));do
    if [ $i -eq 0 ]; then
      echo "    at ${BASH_SOURCE[i]} (${FUNCNAME[i]})" 1>&2
    else
      echo "    at ${BASH_SOURCE[i]} (${FUNCNAME[i]}:${BASH_LINENO[i - 1]})" 1>&2
    fi
  done

  # kill caller
  kill -s TERM "$$"
}

export -f throw