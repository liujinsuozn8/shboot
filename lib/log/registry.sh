import log/common
import log/appender
import string/base
import string/regex
import array/base
import reflect/base
import file/base

################################################################
Log::AppenderRegistry(){
  # Usage: Log::AppenderRegistry appenderName type [key=value]
  local appenderName="$1"
  local type="$2"
  shift 2

  # 1. create inner name
  innerAppenderName="__log_appender_${appenderName}"

  # 2. check appender exist
  Array::Contains "$innerAppenderName" "${Log_Global_Appenders}" && throw "Log Appender[$appenderName] has been registered" 

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
}