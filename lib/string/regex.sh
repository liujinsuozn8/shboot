Regex::Matcher() {
  local num=$3
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: Regex::Matcher "source" "pattern" num
  # Usage: Regex::Matcher "source" "pattern"
  if [ -z "$num" ]; then
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[@]}"
  else
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[${num}]}"
  fi
}
export -f Regex::Matcher