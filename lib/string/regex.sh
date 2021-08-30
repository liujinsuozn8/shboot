Regex_() {
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: regex "string" "regex"
  [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[3]}"
}
