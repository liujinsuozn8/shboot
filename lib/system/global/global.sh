
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
export __boot_global_varnames='__boot_global_varnames'
__init_global_cache

global(){
  if [[ "$1" == *"="* ]]; then
    local pname=${1%%=*}
    local pval=${1#*=}
    eval "$pname='$pval'"

    __boot_global_varnames="$__boot_global_varnames $pname"
  else
    eval "$1=''"
    __boot_global_varnames="$__boot_global_varnames $1"
  fi
}
export -f global

__saveGlobalVar(){
  IFS=$' '
  local k
  for k in $__boot_global_varnames; do
    eval "echo $k=\'\$$k\'" >> "$__boot_global_cache"
  done

  IFS=$'\n'
}
export -f __saveGlobalVar

__recoverGlobalVar(){
  while read -r line || [[ -n ${line} ]]; do
    if [[ -z ${line} ]]; then
      continue
    fi
    eval "$line"
  done < "$__boot_global_cache"

  > "$__boot_global_cache"
}
export -f __recoverGlobalVar