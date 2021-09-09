
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
#---------------------------------------

Array::Contains() {
  # From: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: Array::Contains "target" "${list[@]}"
  local target="$1"
  shift 1

  local element
  for element in "${@}"
  do
    [[ "$element" = "$target" ]] && return 0
  done
  return 1
}
export -f Array::Contains

Array::Join(){
  # Usage: Array::Join 'joinStr' "${array[@]}"
  # Usage: Array::Join 'joinStr' 'aaa' 'bbb' 'ccc'

  local IFS="$1"
  shift 1
  echo "$*"
}
export -f Array::Join