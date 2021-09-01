
throw() {
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: e="Mesage" throw ['...']
  echo "Exception: :$*" 1>&2
  for (( i=0; i<${#BASH_SOURCE[@]}; i++));do
    if [ $i -eq 0 ]; then
      echo "    at ${BASH_SOURCE[i]} (${FUNCNAME[i]})"
    else
      echo "    at ${BASH_SOURCE[i]} (${FUNCNAME[i]}:${BASH_LINENO[i - 1]})"
    fi 
  done

  exit 1000
}