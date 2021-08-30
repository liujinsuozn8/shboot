
throw() {
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: e="Mesage" throw ['...']
  echo "Exception: $*" 1>&2; exit 1000
}