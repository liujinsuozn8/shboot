String::Trim() {
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: String::Trim ' xxx '

  # ' ab cd   ' ---> ' '
  # ' ab cd   ' ---> 'ab cd   '
  # ${_} = 'ab cd   '
  # 'ab cd   ' ----> '   '
  # 'ab cd   ' ----> '   ab cd'

  : "${1#"${1%%[![:space:]]*}"}"
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}
export -f String::Trim

String::StartsWith() {
  # Usage：if String::StartsWith "abc" "ab"

  if [[ "$1" == "$2"* ]];then
    return 0
  else
    return 1
  fi
}
export -f String::StartsWith

String::EndsWith() {
  # Usage：if String::EndsWith "abc" "bc"

  if [[ "$1" == *"$2" ]];then
    return 0
  else
    return 1
  fi
}
export -f String::EndsWith

String::Contains(){
  # Usage：if String::Contains "abcd" "bc"
	if [[ "$1" == *"$2"* ]];then
    return 0
  else
    return 1
  fi
}
export -f String::Contains