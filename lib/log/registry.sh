
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import log/common
import log/appender
import string/base
import string/regex
import array/base
import reflect/base
import file/base

################################################################
Log::AppenderRegistry(){
  export Log__Usable=false

  # Usage: Log::AppenderRegistry appenderName type [key=value]
  local appenderName="$1"
  local type="$2"
  shift 2

  # 1. create inner name
  innerAppenderName="__log_appender_${appenderName}"

  # 2. check appender exist
  Array::Contains "$innerAppenderName" ${Log_Global_Appenders} && throw "Log Appender[$appenderName] has been registered" 

  # 3. registry to cache
  export Log_Global_Appenders="$Log_Global_Appenders"${IFS}"$innerAppenderName"

  # 4. create appender
  # eval declare -Ag $innerAppenderName
  eval export ${innerAppenderName}'_type'=\${type}

  # 5. init (if type is legal)
  if Reflect::isFunction "Log::AppenderRegistry_${type}"; then
    eval Log::AppenderRegistry_${type} "\${appenderName}" "\${innerAppenderName}" "\$@"
  else
    throw "Log Appender[$appenderName]: Can not resolve this type: ${type}"
  fi

  export Log__Usable=true
}
export -f Log::AppenderRegistry

Log::RemoveAppender(){
  export Log__Usable=false

  # Usage: Log::RemoveAppender 'appenderName'
  local appenderName="$1"

  # add prefix
  if [[ "$appenderName" != '__log_appender_'* ]]; then
    appenderName="__log_appender_${appenderName}"
  fi

  if Array::Contains "$appenderName" ${Log_Global_Appenders}; then
    eval local appenderType=\$${appenderName}'_type'

    # remove info of appender
    if [ ! -z "$appenderType" ];then
      eval Log::RemoveAppender_${appenderType} \$appenderName
    fi

    # remove appender
    export Log_Global_Appenders=$(Array::Remove "$appenderName" ${Log_Global_Appenders})
  fi

  if  [ -n "$Log_Global_Appenders" ]; then
    export Log__Usable=true
  fi
}
export -f Log::RemoveAppender

Log::ClearAllAppenders(){
  # Usage: Log::ClearAllAppenders
  export Log__Usable=false


  local appenderName
  for appenderName in ${Log_Global_Appenders[@]}; do
    Log::RemoveAppender "$appenderName"
  done
}
export -f Log::ClearAllAppenders

Log::AppenderIsRegistered(){
  # Usage Log::AppenderIsRegistered 'appenderName'
  local appenderName="$1"

  if [[ "$appenderName" != '__log_appender_'* ]]; then
    appenderName="__log_appender_${appenderName}"
  fi

  eval local appenderType=\${${appenderName}'_type'}
  if [ -z "$appenderType" ]; then
    return 1
  else
    return 0
  fi
}
export -f Log::AppenderIsRegistered