
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

printStackTrace(){
  # Usage: printStackTrace "$___EXCEPTION___"

  if declare -f "Log::ERROR" &> /dev/null; then
    Log::ERROR "\n$1"
  else
    echo -en "\033[0;31m$1\n\033[0m" 1>&2
  fi
}
export -f printStackTrace

Exception::makeExceptionMsg(){
  # Usage: Exception::makeException 'a' 'b' 'c' ....
  local msg="Exception: $*"
  for (( i=0; i<${#BASH_SOURCE[@]}; i++));do
    if [ $i -eq 0 ]; then
      msg="${msg}\n    at ${BASH_SOURCE[i]} (${FUNCNAME[i]})"
    else
      msg="${msg}\n    at ${BASH_SOURCE[i]} (${FUNCNAME[i]}:${BASH_LINENO[i - 1]})"
    fi
  done

  echo "$msg"
}
export -f Exception::makeExceptionMsg

throw() {
  # Usage: throw 'a' 'b' 'c' ....

  # make error
  if [ ! -z "$___in_try_catch___" ]; then
    # handler try...catch...
    Exception::makeExceptionMsg $* >> "$SHBOOT_ROOT/.exception"

    # echo "inner___EXCEPTION___=$___EXCEPTION___"
    return 255
  else
    # if not in try..catch, kill caller
    printStackTrace "$(Exception::makeExceptionMsg $*)"
    kill -TERM "$$"
  fi

  # exit 1 # can not handle:
  #            a=$(throw 'xxx')
  # and try...catch
}
export -f throw

Exception::GetException(){
  # Usage: Exception::GetException 'lastCommandExitCode'
  if [ $1 -ne 255 ]; then
    if [ $1 -eq 127 ]; then
      Exception::makeExceptionMsg "exit 127; Command not find"
    else
      Exception::makeExceptionMsg "exit $1"
    fi
  else
      cat "$SHBOOT_ROOT/.exception"
      > "$SHBOOT_ROOT/.exception";
  fi
}
export -f Exception::GetException