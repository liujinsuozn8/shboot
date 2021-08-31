Regex::Matcher() {
  local num=$3
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: regex "string" "regex"
  if [ -z "$num" ]; then
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[@]}"
  else
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[${num}]}"
  fi
}
