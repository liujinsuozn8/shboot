

# regex 'aaa.sss = ssxs = dd' '([^ =]*) = .*'
# . ./test02.sh
# . ./test03.sh

# a='12345'
# echo ${a:2}

# declare -g __oo__fdPath=$(dirname <(echo))
# declare -gi __oo__fdLength=$(( ${#__oo__fdPath} + 1 ))
# echo $__oo__fdPath
# echo $__oo__fdLength

source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import string/base

# String::Trim '  dd dsss'

# appenders
# rotter 
# threshold
# logPattern
# filename
# 
# filePattern
#

# declare -Ag __log__appenders

# Log::Appenders

#####################
# echo $___boot___

# appenderName='a'
# a_pattern='1234'


# x=1
# echo $x

# eval "x=\${___log_appender_${appenderName}['pattern']}"
# echo $x
#####################

__console__Logger(){
  local appenderName="$1"
  local msg="$2"
  eval "local innerAppenderName=___log_appender_${appenderName}"
  eval "logPattern=\${${innerAppenderName}['pattern']}"

  echo $logPattern $msg
}

declare -Ag __log_appender

LoggerRegistry(){
  # __log_appender["$1"]="$2"
  appenderName="$1"
  logPattern="$2"

  innerAppenderName="___log_appender_${appenderName}"
  eval "declare -Ag $innerAppenderName"
  eval "${innerAppenderName}['pattern']=${logPattern}"
}

LoggerRegistry 'ma' 'mypattern'
# __console__Logger 'ma' 'testmsg'

printf '[%-5s]\n' 'qq'

abc(){
  echo ${FUNCNAME[@]}
}

cde(){
  abc
  echo ${BASH_SOURCE[@]} ${FUNCNAME[-1]}
}
cde
# CreateConsoleLogAppender "ma" "mypattern"
# # CreateConsoleLogAppender 'ma'
# LoggerRegistry 'ma' __console__Logger_ma

# ${__log_appender['ma']} 'test'



# Log::DEBUG 'xxxxxx'
# -->
# for rootLogger
#