
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/base
import string/regex

Properties::Read() {
  # Usage: Properties::Read 'filePath'
  local result=( )
  local line
  while read -r line || [[ -n ${line} ]]; do
    line=$(String::Trim "$line")
    
    if [ ! -z "$line" ] && ! String::StartsWith "$line" '#'; then
      result+=( "$line" )
    fi

  done < "$1"

  printf '%s\n' "${result[@]}"
}

Properties::GetKeyAndValue() {
  # Usage: Properties::GetKeyAndValue 'filePath'
  local result=( )
  local line
  while read -r line || [[ -n ${line} ]]; do
    line=$(String::Trim "$line")
    
    if [ ! -z "$line" ] && ! String::StartsWith "$line" '#'; then
      local matcher=( $(Regex::Matcher "$line" '([^= ]+)[[:space:]]*=[[:space:]]*(.*)') )
      if [ ${#matcher[@]} -ne 3 ];then
        throw "Illegal text. Can not resolve this text. Maybe value is not set. text: ${line}"
      fi

      result+=( "${matcher[1]}" "${matcher[2]}" )
    fi

  done < "$1"

  printf '%s\n' "${result[@]}"
}
