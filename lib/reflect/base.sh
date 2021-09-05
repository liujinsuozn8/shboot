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