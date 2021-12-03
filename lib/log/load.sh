
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import file/kvfile
import string/base
import array/base
import log/base
import log/common
import log/registry
import log/appender

###########################

Log::LoadDefaultAppender(){
  # Usage: Log::LoadDefaultAppender
  Log::AppenderRegistry 'DefalutAppender' 'Console' \
    "-LogPattern=${Log__DefalutLogPattern}" \
    -Threshold='DEBUG'
}
export -f Log::LoadDefaultAppender

###########################
# __findRootLogger(){
#   local kvs=( "$@" )

#   for (( i=0; i<${#kvs[@]}; i++)) do
#     local k=${kvs[i]}
#     local v=${kvs[i+1]}

#     if [ "$k" == 'rootLogger' ]; then
#       echo "$v"
#       return 0
#     fi

#     ((i=i+1))
#   done
# }

###########################
Log::LoadPropertiesAppender(){
  # Usage: Log::LoadPropertiesAppender 'propertiesPath'
  export Log_Global_Appenders=''

  local kvs=( $(KVFile::GetAllKeyAndValue "$1" ) )
  local rootLogger=''
  local i

  # 1. findRootLogger
  for (( i=0; i<${#kvs[@]}; i++)) do
    local k=${kvs[i]}
    local v=${kvs[i+1]}

    if [ "$k" == 'rootLogger' ]; then
      rootLogger="$v"
      break
    fi

    ((i=i+1))
  done

  if [ -z "$rootLogger" ]; then
    throw "Unable to load :${1}.\nBecause 'rootLogger' could not be found in"
  fi

  # 2. check rootLogger
  local rootLogger=( ${rootLogger//,/$IFS} )
  local logLevelStr=$(String::Trim "${rootLogger[0]}")

  if Log::isAvailableLevelStr "$logLevelStr"; then
    export Log_Root_Level=${!logLevelStr}
  else
    throw "Unable to load :${1}.\nIllegal rootLogger. LogLevel must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $logLevelStr"
  fi

  # 3. Get appender from rootLogger and Check
  local rootAppenders=( )
  local i
  for (( i=1; i<${#rootLogger[@]}; i++)) do
    rootAppenders+=( $(String::Trim "${rootLogger[i]}") )
  done

  if [ ${#rootAppenders[@]} -eq 0 ]; then
    throw "Unable to load :${1}.\nIllegal rootLogger. Appender not set. rootLogger=$rootLogger"
  fi

  # 4. load
  local curAppenderName=''
  local lastAppenderName=''
  local appenderType=''
  local parameters=( )
  for (( i=0; i<${#kvs[@]}; i++)) do
    local k=${kvs[i]}
    local v=${kvs[i+1]}
    
    ((i=i+1))
    
    if [[ "$k" == "appender."* ]];then
      # appender.RF.Policies.OnStartupTriggeringPolicy --> RF.Policies.OnStartupTriggeringPolicy
      k=${k#appender.}
      # RF.Policies.OnStartupTriggeringPolicy --> RF
      curAppenderName=${k%%.*}

      # if curAppenderName not in rootAppenders, TO next
      if ! Array::Contains "$curAppenderName" "${rootAppenders[@]}"; then
        continue
      fi

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

  local appender
  for appender in ${rootAppenders[@]}; do
    if ! Log::AppenderIsRegistered "$appender" ; then
      throw "Unable to load :${1}.\nIllegal rootLogger. The configuration of appender:[${appender}] does not exist"
    fi
  done
}
export -f Log::LoadPropertiesAppender
###########################

Log::ReLoadAppender(){
  # find custom log.conf
  local customPropertiesPath="${START_SHEEL_DIR}/resources/log.conf"

  # clear other appender
  Log::ClearAllAppenders

  # load appender
  if [ -f "$customPropertiesPath" ];then
    Log::LoadPropertiesAppender "$customPropertiesPath"
  elif [ -f "$Log__PropertiesPath" ]; then
    Log::LoadPropertiesAppender "$Log__PropertiesPath"
  else
    Log::LoadDefaultAppender
  fi
}