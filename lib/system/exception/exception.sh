
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
  local msg="Exception: $*\n"
  for (( i=0; i<${#BASH_SOURCE[@]}; i++));do
    if [ $i -eq 0 ]; then
      msg="${msg}    at ${BASH_SOURCE[i]} (${FUNCNAME[i]})\n"
    else
      msg="${msg}    at ${BASH_SOURCE[i]} (${FUNCNAME[i]}:${BASH_LINENO[i - 1]})\n"
    fi
  done

  echo "$msg"
}
export -f Exception::makeExceptionMsg

throw() {
  # Usage: throw 'a' 'b' 'c' ....

  # make error
  ___EXCEPTION___=$(Exception::makeExceptionMsg $*)

  # handler try...catch...
  if [ "$___in_try_catch___" == '___in_try_catch___' ]; then
    return 1
  else
    # if not in try..catch, kill caller
    printStackTrace "$___EXCEPTION___"
    kill -TERM "$$"
  fi

  # exit 1 # can not handle:
  #            a=$(throw 'xxx')
  # and try...catch
}
export -f throw

alias try="___EXCEPTION___=''; ___in_try_catch___='___in_try_catch___'; ("
alias catch='); ___result___=$?; [ -z "$___EXCEPTION___" ] && ___EXCEPTION___=$(Exception::makeExceptionMsg "exit $___result___"); unset ___in_try_catch___; [ $___result___ -eq 0 ] && unset ___result___ ||'

