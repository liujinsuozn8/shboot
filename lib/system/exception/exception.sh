
throw() {
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: e="Mesage" throw ['...']
  eval 'cat <<< "Exception: $e ($*)" 1>&2; read -s;';
}