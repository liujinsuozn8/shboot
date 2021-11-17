
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
# alias try='
#   if [ -z "$___in_try_catch___" ]; then
#     export ___in_try_catch___=0
#     export ___EXCEPTION___=""

#     __init_exception_cache
#   fi
#   ((___in_try_catch___+=1))
#   export ___setOps___=$(echo $-); set +e; (set -e; trap __saveGlobalVar EXIT INT TERM HUP QUIT ABRT;'
alias try='[ -z "$___in_try_catch___" ] && export ___in_try_catch___=0 && __init_exception_cache; ((___in_try_catch___+=1)); export ___setOps___=$(echo $-); set +e; (set -e; trap __saveGlobalVar EXIT INT TERM HUP QUIT ABRT;'

alias catch='); ___exitCode___=$?; [ $___exitCode___ -ne 0 ] && ___EXCEPTION___=$(Exception::GetException $___exitCode___); ((___in_try_catch___-=1)); [ $___in_try_catch___ -eq 0 ] && unset ___in_try_catch___; __recoverGlobalVar; set -"$___setOps___"; [ $___exitCode___ -eq 0 ] && unset ___exitCode___ ||'

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
    Exception::makeExceptionMsg $* >> "$__boot_exception_cache"

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
    cat "$__boot_exception_cache"
    > "$__boot_exception_cache"
  fi
}
export -f Exception::GetException