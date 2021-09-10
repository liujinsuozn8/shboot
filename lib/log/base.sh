
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import log/common
import log/registry
import log/appender
import date/base
import string/base

########################################
__populate_msg(){
  # __populate__log appenderName timestamp levelId msg shell method
  local appenderName="$1"
  local timestamp="$2"

  # 1. get config of appender
  eval local logPattern=\${${appenderName}'_logPattern'}
  
  # 2. get paramter
  local level="$(String::LJust 5 "$3")"
  local msg="$4"
  local shell="$5"
  local method="$6"

  # 3. Create time string And Replace time format with it
  logPattern=$(Log::PopulateTime "$timestamp" "$logPattern")

  # 4. populate message
  eval echo $logPattern
}
export -f __populate_msg

Log::Output(){
  # Usage: Log::Output levelId msg shell method
  local levelId=$1

  # Get timestamp
  local timestamp=$(Date::NowTimestamp)

  local appenderName
  for appenderName in ${Log_Global_Appenders[@]}; do
    # 1. check level
    eval local threshold=\${${appenderName}'_threshold'}
    if [[ ${!levelId} -lt $threshold ]]; then
      continue
    fi

    # 2. populate msg
    local msg=$(__populate_msg "$appenderName" "$timestamp" "$@")

    # 3. output log （to console or file）
    eval local appenderType=\${${appenderName}'_type'}

    # concurrent execution
    eval "Log::Output_${appenderType}" "$levelId" "\$appenderName" "\$timestamp" "\$msg" &
  done

  wait
}
export -f Log::Output

########################################

Log::DEBUG() {
  # Usage: Log::DEBUG 'msg'
  Log::Output DEBUG "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::INFO() {
  # Usage: Log::INFO 'msg'
  Log::Output INFO "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::WARN() {
  # Usage: Log::WARN 'msg'
  Log::Output WARN "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::ERROR() {
  # Usage: Log::ERROR 'msg'
  Log::Output ERROR "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::FATAL() {
  # Usage: Log::FATAL 'msg'
  Log::Output FATAL "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}


export -f Log::DEBUG

export -f Log::INFO

export -f Log::WARN

export -f Log::ERROR

export -f Log::FATAL