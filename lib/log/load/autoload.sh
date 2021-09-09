import file/properties
import string/base
import array/base
import log/base
import log/registry
import log/appender

###########################
__findRootLogger(){
  local kvs=( "$@" )

  for (( i=0; i<${#kvs[@]}; i++)) do
    local k=${kvs[i]}
    local v=${kvs[i+1]}

    if [ "$k" == 'rootLogger' ]; then
      echo "$v"
      return 0
    fi

    ((i=i+1))
  done
}


kvs=( $(Properties::GetKeyAndValue "${PROJECT_ROOT}/resource/log.properties") )
rootLogger=$(__findRootLogger "${kvs[@]}")
if [ -z "$rootLogger" ]; then
  throw "Unable to load :${PROJECT_ROOT}/resource/log.properties.\nBecause 'rootLogger' could not be found in"
fi

# check rootLogger
rootLogger=( ${rootLogger//,/$IFS} )
logLevelStr=$(String::Trim "${rootLogger[0]}")

if Log::isAvailableLevelStr "$logLevelStr"; then
  export Log__DefalutLevel=${!logLevelStr}
else
  throw "Unable to load :${PROJECT_ROOT}/resource/log.properties.\nIllegal rootLogger. LogLevel must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $logLevelStr"
fi

# Get appender from rootLogger and Check
rootAppenders=( )
for (( i=1; i<${#rootLogger[@]}; i++)) do
  rootAppenders+=( $(String::Trim "${rootLogger[i]}") )
done

if [ ${#rootAppenders[@]} -eq 0 ]; then
  throw "Unable to load :${PROJECT_ROOT}/resource/log.properties.\nIllegal rootLogger. Appender not set. rootLogger=$rootLogger"
fi

# load
curAppenderName=''
lastAppenderName=''
appenderType=''
parameters=( )
for (( i=0; i<${#kvs[@]}; i++)) do
  local k=${kvs[i]}
  local v=${kvs[i+1]}
  
  ((i=i+1))
  
  if [[ "$k" == "appender."* ]];then
    # appender.RF.Policies.OnStartupTriggeringPolicy --> RF.Policies.OnStartupTriggeringPolicy
    k=${k#appender.}
    # RF.Policies.OnStartupTriggeringPolicy --> RF
    curAppenderName=${k%%.*}
    # RF.Policies.OnStartupTriggeringPolicy --> Policies.OnStartupTriggeringPolicy
    local parameter=${k#${curAppenderName}}
    # Policies.OnStartupTriggeringPolicy --> PoliciesOnStartupTriggeringPolicy
    parameter=${parameter//./}

    if [ "$curAppenderName" != "$lastAppenderName" ]; then
      if [ -z "$lastAppenderName" ]; then
        lastAppenderName="$curAppenderName"
      else

        Array::Contains "$lastAppenderName" "${rootAppenders[@]}" && Log::AppenderRegistry "$lastAppenderName" "$appenderType" "${parameters[@]}"
        lastAppenderName="$curAppenderName"
        parameters=( )
      fi
    fi

    if [ -z "$parameter" ]; then
      appenderType="$v"
    else
      parameters+=( "-${parameter}=${v}" )
    fi
  fi
done

Array::Contains "$lastAppenderName" "${rootAppenders[@]}" && Log::AppenderRegistry "$lastAppenderName" "$appenderType" "${parameters[@]}"
