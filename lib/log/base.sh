import log/registry

########################################

__output_log_Console(){
  # Usage: __output_log_Console appenderName msg
  echo "$2"
}

__populate_msg(){
  # __populate__log appenderName levelId msg shell method
  local appenderName="$1"

  # get config of appender
  eval local logPattern=\${${appenderName}['logPattern']}
  eval local logTimeFormat=\${${appenderName}['logTimeFormat']-\${Log__DefalutLogTimeFormat}}
  
  # populate log
  local levelId="$2"
  local msg="$3"
  local shell="$4"
  local method="$5"

  local level="${Log__LevelStr[$levelId]}"
  local time=$( printf "%(${logTimeFormat})T" "-1" )

  eval echo $logPattern
}

__log(){
  # Usage: __print_log levelId msg shell method
  local levelId=$1

  if [[ $levelId -lt $Log_Root_Level ]]; then
    return 0
  fi

  local appenderName
  for appenderName in ${Log_Global_Appender[@]}; do
    # 1. check level
    eval local threshold="\${${appenderName}['threshold']}"
    if [[ $levelId -lt $threshold ]]; then
      continue
    fi

    # 2. populate msg
    local msg="$(__populate_msg "$appenderName" "$@")"

    # 3. output log （to console or file）
    eval local appenderType="\${${appenderName}['type']}"
    eval "__output_log_${appenderType}" "\$appenderName" "\$msg"
  done
}

########################################

Log::DEBUG() {
  # Usage: Log::DEBUG 'msg'
  __log DEBUG "$1" "${BASH_SOURCE[-1]--}" "${FUNCNAME[-1]--}"
}

Log::INFO() {
  # Usage: Log::INFO 'msg'
  __log INFO "$1" "${BASH_SOURCE[-1]--}" "${FUNCNAME[-1]--}"
}

Log::WARN() {
  # Usage: Log::WARN 'msg'
  __log WARN "$1" "${BASH_SOURCE[-1]--}" "${FUNCNAME[-1]--}"
}

Log::ERROR() {
  # Usage: Log::ERROR 'msg'
  __log ERROR "$1" "${BASH_SOURCE[-1]--}" "${FUNCNAME[-1]--}"
}

Log::FATAL() {
  # Usage: Log::FATAL 'msg'
  __log FATAL "$1" "${BASH_SOURCE[-1]--}" "${FUNCNAME[-1]--}"
}