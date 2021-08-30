
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

String::StartsWith() {
  # Usage：if String::StartsWith "$a" "$b"

  if [[ "$1" == "$2"* ]];then
    return 0
  else
    return 1
  fi
}