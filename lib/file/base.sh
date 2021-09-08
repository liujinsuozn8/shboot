File::TryTouch(){
  # Usage: File::TryTouch 'filePath'

  # 1. paramter check
  if ! File::IsFilePathStr "$1"; then
    return 100
  fi

  # 2. mkdir
  local d="${1%/*}"
  mkdir -p "$d"

  local result=$?
  if [ $result -ne 0 ]; then
    return $result
  fi

  # 3. touch
  touch "$1"
  
  return $?
}
export -f File::TryTouch

File::IsFilePathStr(){
  # Usage: File::isFilePath 'path'
  if String::EndsWith "$1" '..' || String::EndsWith "$1" '/' ; then
    return 1
  else
    return 0
  fi
}
export -f File::IsFilePathStr

File::ClearFile(){
  # Usage: File::ClearFile 'filePath'
  if [ -f "$1" ]; then
    > "$1"
  fi
}
export -f File::ClearFile

File::Basename() {
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: File::Basename "path" ["fileSuffix"]
  local tmp

  tmp=${1%"${1##*[!/]}"}
  tmp=${tmp##*/}
  tmp=${tmp%"${2/"$tmp"}"}

  printf '%s\n' "${tmp:-/}"
}
export -f File::Basename

File::Dirname() {
  # from: https://github.com/dylanaraps/pure-bash-bible
  # Usage: File::Dirname "path"
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
export -f File::Dirname

File::AbsPath() {
  # from: http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
  # from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  # Usage: File::AbsPath 'relative filename'
  # $1 : relative filename
  local file="$1"
  if [[ "$file" == "/"* ]]
  then
    echo "$file"
  else
    echo "$(cd "$(Builtin::Dirname "$file")" && pwd)/$(Builtin::Basename "$file")"
  fi
}
export -f File::AbsPath

File::CanCreateFileInDir() {
  # Usage: File::CanCreateFileInDir 'dir'

  # check1: $1 is a dir ?
  [ ! -d "$1" ] && return 1

  # check2: can create file?
  [ -w "$1" ] && [ -x "$1" ] && return 0

  # # can not create file
  return 1
}
export -f File::CanCreateFileInDir

File::GrepCountFromFilePath(){
  # Usage: File::GrepCountFromFilePath 'filePathRegex'
  local ptnDir="$(File::Dirname "$1")"
  local ptnFile="$(File::Basename "$2")"
  
  File::GrepCountFromDir "$ptnDir" "$ptnFile"
}
export -f File::GrepCountFromFilePath

File::GrepCountFromDir(){
  # Usage: File::GrepCountFromDir 'dir' 'filenameRegex'
  if [ ! -e "$1" ]; then
    echo '0'
    return 0
  fi

  ls "$1" | grep -E "$2" | wc -l
}
export -f File::GrepCountFromDir

# Compatible with MAC OS
if [ "$(uname)" == 'Darwin' ]; then
  # for Mac
  File::ATime(){
    # Usage: File::ATime 'filePath'
    stat -f '%a' "$1"
  }
  export -f File::ATime

  File::MTime(){
    # Usage: File::MTime 'filePath'
    stat -f '%m' "$1"
  }
  export -f File::MTime

  File::CTime(){
    # Usage: File::CTime 'filePath'
    stat -f '%c' "$1"
  }
  export -f File::CTime

else

  File::ATime(){
    # Usage: File::ATime 'filePath'
    stat -c %X "$1"
  }
  export -f File::ATime

  File::MTime(){
    # Usage: File::MTime 'filePath'
    stat -c %Y "$1"
  }
  export -f File::MTime

  File::CTime(){
    # Usage: File::CTime 'filePath'
    stat -c %Z "$1"
  }
  export -f File::CTime
fi


# ls test| grep -E 'qqq-[0-9]+.log$' | wc -l
# while read -r line; do
#   line=$(String_trim $line)
  
#   # file_data+=("$line")

#   if [ ! -z $line ] && (! String_startsWith "$line" '#');then
#     # echo "$line"
#     key=${line%%=*}
#     echo $key
#   fi

# done < "./resource/log.properties"

# # for x in ${file_data[@]};do
# # 	echo "$x"
# # done