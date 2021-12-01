#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/regex

Random::NumAndEnStr(){
  # Random::NumAndEnStr strLength
  if [[ $# -ne 1 ]] || Regex::IsUnsignedInt "$1"; then
    return 1
  fi

  local nums="0123456789"
  local upperEN="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local lowerEN="abcdefghijklmnopqrstuvwxyz"

  local i
  local result=''
  for ((i=0; i<$1; i++)); do
    case $(($RANDOM%4)) in
      0|1) result="$result${nums:$(($RANDOM%10)):1}" ;;
      2) result="$result${upperEN:$(($RANDOM%26)):1}" ;;
      3) result="$result${lowerEN:$(($RANDOM%26)):1}" ;;
    esac
  done

  echo "$result"
}
export -f Random::NumAndEnStr