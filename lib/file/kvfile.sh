
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/base

KVFile::GetValue(){
  # Usage: KVFile::GetAllKeyAndValue 'filePath' 'key'
  if [[ -z "$1" ]] || [[ ! -e "$1" ]] || [[ -z "$2" ]]; then
    return 1
  fi

  local k
  local v
  local IFS=' = '
  local result=''
  while read k v; do
    v="${v//$'\r'}"

    if [[ -z "$k" ]] || String::StartsWith "$k" '#' || [[ -z "$v" ]]; then
      continue
    fi

    if [[ "$k" == "$2" ]]; then
      result="$v"
      break
    fi
  done < "$1"

  echo "$result"
}

KVFile::GetAllKeyAndValue(){
  # Usage: KVFile::GetAllKeyAndValue 'filePath'
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

    v="${v//$'\r'}"

    if [[ -z "$k" ]] || String::StartsWith "$k" '#' || [[ -z "$v" ]]; then
      continue
    fi

    result+=( "$k" "$v" )
  done < "$1"

  printf '%s\n' "${result[@]}"
}