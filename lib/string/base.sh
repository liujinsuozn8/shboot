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

String::LJust() {
  # Usage: String::LJust 'width' 'string' 'fillchar'
  # Usage: String::LJust 'width' 'string'
  #        If the parameter: fillchar is not specified, spaces will be used
  
  local width=$1
  local string="$2"

  # if width <= 0 then return
  if [ $width -le 0 ];then
    echo "$string"
    return 0
  fi

  local fillchar="${3- }"

  # Trim Left And If Len(temp) <= width then return
  local temp="${string#"${string%%[![:space:]]*}"}"
  if [ ${#temp} -ge $width ];then
    echo "$temp"
    return 0
  fi

  # add replace string
  : $((width = $width - ${#temp}))
  # Original code: 
  # x=$(printf "${fillchar}%.0s" ${width})
  eval local repeatStr=\$\(printf \"${fillchar}%.0s\" {1\.\.${width}}\)

  echo "${temp}${repeatStr}"
}
export -f String::LJust