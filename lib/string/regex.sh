Regex::Matcher() {
  local num=$3
  [ -z "$num" ] && num='@'
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: regex "string" "regex"
  [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[${num}]}"
}
