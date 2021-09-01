File::TryTouch(){
  # Usage: File::Mkdir 'filePath'

  # 1. paramter check
  if ! File::isFilePathStr "$1"; then
    return 100
  fi

  # 2. mkdir
  local d=${1%/*}
  mkdir -p "$d"
  
  if [ $? -ne 0]; then
    return $?
  fi

  # 3. touch
  touch "$1"
  
  return $?
}

File::isFilePathStr(){
  # Usage: File::isFilePath 'path'
  if String::EndsWith "$filePath" '..' || String::EndsWith "$filePath" '/' ; then
    return 1
  else
    return 0
  fi
}

File::clearFile(){
  # Usage: File::clearFile 'filePath'
  if [ -f "$1" ]; then
    > "$1"
  fi
}
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