import file/properties
import string/base
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
  logLevel=${!logLevelStr}
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

# curAppender=''
# for (( i=0; i<${#kvs[@]}; i++)) do
#   local k=${kvs[i]}
#   local v=${kvs[i+1]}
  
#   ((i=i+1))
  
#   if [[ "$k" == "appender."* ]];then
    
#   fi
# done



# if [[ $a =~  ]];then
#   echo 'bbbb'
# else
#   echo 'vvvv'
# fi

# rootLoggerConfig=( )

# echo "rootLogger.count=${#rootLogger[@]}"
# echo "$rootLogger[@]"


# lastAppenderName=''
