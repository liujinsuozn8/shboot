
throw() {
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: e="Mesage" throw ['...']
  echo "Exception: shell:[${BASH_SOURCE[1]}] method:[${FUNCNAME[1]}] lineNo:[${BASH_LINENO[0]}] message:$*" 1>&2; exit 1000
}