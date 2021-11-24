
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
# alias try='[ -z "$___in_try_catch___" ] && export ___in_try_catch___=0 && __init_exception_cache; ((___in_try_catch___+=1)); export ___setOps___="$-"; set +e; (set -e; addTrap "__getErrorInfoInTrap" EXIT; addTrap "__saveGlobalVar" EXIT INT ABRT; exec 2> "$__boot_exception_cache";'
alias try='[ -z "$___in_try_catch___" ] && export ___in_try_catch___=0 && __init_exception_cache; ((___in_try_catch___+=1)); export ___setOps___="$-"; set +e; (set -e; addTrap "__getErrorInfoInTrap" EXIT; addTrap "__saveGlobalVar" EXIT INT ABRT; '

alias catch='); ___exitCode___=$?; [ $___exitCode___ -ne 0 ] && ___EXCEPTION___=$(Exception::GetException $___exitCode___); ((___in_try_catch___-=1)); [ $___in_try_catch___ -eq 0 ] && unset ___in_try_catch___; __recoverGlobalVar; set -"$___setOps___"; [ $___exitCode___ -eq 0 ] && unset ___exitCode___ ||'

printStackTrace(){
  # Usage: printStackTrace "$___EXCEPTION___"
  if declare -f "Log::ERROR" &> /dev/null; then
    Log::ERROR "\n$1"
  else
    echo -e "\033[0;31m$1\033[0m"
  fi
}
export -f printStackTrace

throw() {
  # Usage: throw 'a' 'b' 'c' ....

  # make error
  if [ ! -z "$___in_try_catch___" ]; then
    # handler try...catch...
    # cache message of throw by ___EXCEPTION___
    # this cache will be used and setted full message in `catch`
    ___EXCEPTION___="$*"
    exit 255
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

# only be called by addTrap
__getErrorInfoInTrap(){
  if [ $exitCode -eq 0 ]; then
    return
  fi

  if [ $exitCode -ne 255 ]; then
    if [ $exitCode -eq 127 ]; then
      Exception::makeExceptionMsg "exitCode=127; Command not find" >> "$__boot_exception_cache"
    else
      Exception::makeExceptionMsg "exitCode=$exitCode" >> "$__boot_exception_cache"
    fi
  else
    Exception::makeExceptionMsg "$___EXCEPTION___" >> "$__boot_exception_cache"
  fi
}
export -f __getErrorInfoInTrap

Exception::makeExceptionMsg(){
  # Usage: Exception::makeException 'a' 'b' 'c' ....
  local msg="Exception: $*"

  # get exception info from cache file
  # if [ -n "$__boot_exception_cache" ]; then
  #   local exceptionCache=$(cat $__boot_exception_cache)
  #   if [[ -n "$exceptionCache" ]]; then
  #     msg="$msg\n${exceptionCache}"
  #   fi
  # fi

  # i from 1, skip itself
  # must skip:
  #     1. lib/system/keyword/exception.sh
  #     2. lib/system/builtin/method.sh
  local skip='.*lib/system/(keyword/exception.sh|builtin/method.sh)$'
  for (( i=1; i<${#BASH_SOURCE[@]}; i++));do
    if [[ "${BASH_SOURCE[i]}" =~ $skip ]]; then
      continue
    else
      msg="${msg}\n    at ${BASH_SOURCE[i]} (${FUNCNAME[i]}:${BASH_LINENO[i - 1]})"
    fi
  done

  echo "$msg"
}
export -f Exception::makeExceptionMsg

Exception::GetException(){
  # Usage: Exception::GetException
  if [[ -e "$__boot_exception_cache" ]] && [[ -s "$__boot_exception_cache" ]]; then
    cat "$__boot_exception_cache"
    > "$__boot_exception_cache"
  else
    echo ''
  fi
}
export -f Exception::GetException