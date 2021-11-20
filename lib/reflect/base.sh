
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

Reflect::isFunction(){
  # Usage: 
  #      Reflect::isFunction 'functionName'
  #      if Reflect::isFunction 'functionName';then
  
  if [[ $(type -t "$1") == 'function' ]]; then
    return 0
  else
    return 1
  fi
}
export -f Reflect::isFunction

Reflect::isCommand(){
  # Usage: 
  #      Reflect::isCommand functionName
  #      if Reflect::isCommand functionName;then

  # from:
  # https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script/677212#677212
  eval command -v $1 &>/dev/null && return 0 || return 1
}
export -f Reflect::isCommand