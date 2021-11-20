
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

Builtin::Basename() {
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: Builtin::Basename "path" ["fileSuffix"]
  local tmp

  tmp=${1%"${1##*[!/]}"}
  tmp=${tmp##*/}
  tmp=${tmp%"${2/"$tmp"}"}

  printf '%s\n' "${tmp:-/}"
}
export -f Builtin::Basename

Builtin::Dirname() {
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: Builtin::Dirname "path"
  local tmp=${1:-.}

  [[ $tmp != *[!/]* ]] && {
      printf '/\n'
      return
  }

  tmp=${tmp%%"${tmp##*[!/]}"}

  [[ $tmp != */* ]] && {
      printf '.\n'
      return
  }

  tmp=${tmp%/*}
  tmp=${tmp%%"${tmp##*[!/]}"}

  printf '%s\n' "${tmp:-/}"
}
export -f Builtin::Dirname