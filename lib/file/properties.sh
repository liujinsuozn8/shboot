
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/base

Properties::GetKeyAndValue(){
  # Usage: Properties::GetKeyAndValue 'filePath'
  if [[ -z "$1" ]] || [[ ! -e "$1" ]]; then
    return 1
  fi
  local result=( )
  local k
  local v

  local IFS=' = '
  while read k v; do
    # skip:
    # k is empty
    # k StartsWith #
    # v is empty
    if [[ -z "$k" ]] || String::StartsWith "$k" '#' || [[ -z "$v" ]]; then
      continue
    fi
    
    result+=( "$k" "$v" )
  done < "$1"

  printf '%s\n' "${result[@]}"
}