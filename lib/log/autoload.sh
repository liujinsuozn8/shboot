import file/properties
import string/base
import log/base
import log/registry
import log/appender

###########################
__findRootLogger(){
  # echo "$@"
  local kvs=( "$@" )
  # echo "${kvs[@]}"
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
  throw ""
fi

# lastAppenderName=''
# for (( i=0; i<${#kvs[@]}; i++)) do
#   local k=${kvs[i]}
#   local v=${kvs[i+1]}
  
#   ((i=i+1))
  
#   case "$k" in
#     rootLogger)
#     ;;
#     appender.*)
#     ;;
#   esac
# done