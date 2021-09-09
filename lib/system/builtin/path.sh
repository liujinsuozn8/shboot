
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
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

Builtin::AbsPath() {
  # from: http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: Builtin::AbsPath 'relative filename'
  # $1 : relative filename
  local file="$1"
  if [[ "$file" == "/"* ]]
  then
    echo "$file"
  else
    echo "$(cd "$(Builtin::Dirname "$file")" && pwd)/$(Builtin::Basename "$file")"
  fi
}
export -f Builtin::AbsPath