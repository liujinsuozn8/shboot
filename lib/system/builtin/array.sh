
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
#---------------------------------------

Builtin::ArrayContains() {
  # From: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: Builtin::ArrayContains "target" "${list[@]}"
  local element
  for element in "${@:2}"
  do
    [[ "$element" = "$1" ]] && return 0
  done
  return 1
}

export -f Builtin::ArrayContains