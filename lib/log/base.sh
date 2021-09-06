import log/common
import log/registry
import log/appender
import date/base
import string/base

########################################
__populate_msg(){
  # __populate__log appenderName levelId msg shell method
  local appenderName="$1"

  # 1. get config of appender
  eval local logPattern=\${${appenderName}'_logPattern'}
  
  # 2. get paramter
  local levelId="$2"
  local msg="$3"
  local shell="$4"
  local method="$5"
  local level="${Log__LevelStr[$levelId]}"

  # 3. Create time string And Replace time format with it
  # 3.1 Get timestamp
  local timestamp=$(Date::NowTimestamp)
  logPattern=$(Log::PopulateTime "$timestamp" "$logPattern")

  # 4. populate message
  eval echo $logPattern
}
export -f __populate_msg

LogOutput(){
  # Usage: __print_log levelId msg shell method
  local levelId=$1
  if [[ $levelId -lt $Log_Root_Level ]]; then
    return 0
  fi

  local appenderName
  for appenderName in ${Log_Global_Appenders[@]}; do
    # 1. check level
    eval local threshold=\${${appenderName}'_threshold'}
    if [[ $levelId -lt $threshold ]]; then
      continue
    fi

    # 2. populate msg
    local msg=$(__populate_msg "$appenderName" "$@")

    # 3. output log （to console or file）
    eval local appenderType=\${${appenderName}'_type'}
    eval "LogOutput_${appenderType}" "\$appenderName" "\$msg"
  done
}
export -f LogOutput

########################################

Log::DEBUG() {
  # Usage: Log::DEBUG 'msg'
  LogOutput DEBUG "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::INFO() {
  # Usage: Log::INFO 'msg'
  LogOutput INFO "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::WARN() {
  # Usage: Log::WARN 'msg'
  LogOutput WARN "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::ERROR() {
  # Usage: Log::ERROR 'msg'
  LogOutput ERROR "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}

Log::FATAL() {
  # Usage: Log::FATAL 'msg'
  LogOutput FATAL "$1" "${BASH_SOURCE[1]}" "${FUNCNAME[1]}"
}


export -f Log::DEBUG

export -f Log::INFO

export -f Log::WARN

export -f Log::ERROR

export -f Log::FATAL