
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

var(){
  if [[ "$1" == *"="* ]]; then
    local pname=${1%%=*}
    local pval=${1#*=}
    eval "$pname='$pval'"

    if [[ -n "$___in_try_catch___" && "$___in_try_catch___" != "0" ]]; then
      # if in try-catch, write param to file
      echo "$pname='$pval'" >> $SHBOOT_ROOT/.var
    fi
  fi
}
export -f var

__recoverVar(){
  while read -r line || [[ -n ${line} ]]; do
    if [[ -z ${line} ]]; then
      continue
    fi
    eval "$line"
  done < "$SHBOOT_ROOT/.var"

  if [[ -z "$___in_try_catch___" || "$___in_try_catch___" == "0" ]]; then
    # if out try-catch, clear file
    > "$SHBOOT_ROOT/.var"
  fi
}
export -f __recoverVar