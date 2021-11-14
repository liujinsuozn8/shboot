
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

Builtin::ArrayContains() {
  # From: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: Builtin::ArrayContains "target" "${list[@]}"
  local target="$1"
  shift 1

  local element
  for element in "${@}"
  do
    [[ "$element" = "$target" ]] && return 0
  done
  return 1
}

export -f Builtin::ArrayContains