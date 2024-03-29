
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

################################################################
# log level
export DEBUG=0
export INFO=1
export WARN=2
export ERROR=3
export FATAL=4

################################################################
export Log_Root_Level=$DEBUG

#declare -g Log__DefalutLogTimeFormat='%Y/%m/%d %H:%M:%S'
export Log__DefalutLogTimeFormat='yyyy/MM/dd HH:mm:ss'
export Log__DefalutLogPattern='${time} [${level}] Method:[${shell} ${method}] msg:${msg}'

export Log__Type_Console='Console'
export Log__Type_RandomAccessFile='RandomAccessFile'
export Log__Type_DailyRollingFileAppender='DailyRollingFileAppender'

export Log__PropertiesPath="${SHBOOT_ROOT}/resources/log.conf"

export Log__Usable=false
################################################################
# registry appender
# !!! Replace the array with a string that connected with IFS !!!
# !!! Compatible with Mac, execute export where this variable is actually created / modified !!!
# !!! For Mac, if you execute export here, you cannot get the variable in the subshell !!!
if [ "$(uname)" != 'Darwin' ]; then
  export Log_Global_Appenders=''
fi

################################################################

Log::PopulateTime(){
  # Usage: Log::PopulateTime "timestamp" "pattern"
  local timestamp="$1"
  local pattern="$2"

  # 1 Extract time format string
  # 'xxx ${time:0:23}{%Y/%m/%d %H:%M:%S} xxxxx' -----> ${time}{%Y/%m/%d %H:%M:%S}
  local timeConfig=$(Regex::Matcher "$pattern" '.*(\$\{time\}\{[^\{\}]*\}).*' 1)
  while [ -n "$timeConfig" ]; do
    # 2 ${time:0:23}{%Y/%m/%d %H:%M:%S} -----> %Y/%m/%d %H:%M:%S
    local logTimeFormat=$(Regex::Matcher "$timeConfig" '\$\{time\}\{([^\{\}]*)\}' 1)
    if [ -z "$logTimeFormat" ]; then
      logTimeFormat="$Log__DefalutLogTimeFormat"
    fi

    # 3 create and replace
    local timeStr=$(Date::Format "$timestamp" "${logTimeFormat}")
    pattern="${pattern/$timeConfig/$timeStr}"

    # 4 get next timeConfig
    timeConfig=$(Regex::Matcher "$pattern" '.*(\$\{time\}\{[^\{\}]*\}).*' 1)
  done


  # 5. 'xxx ${time:0:23} xxxxx' -----> ${time}
  timeConfig=$(Regex::Matcher "$pattern" '.*(\$\{time\}).*' 1)
  while [ -n "$timeConfig" ]; do
    logTimeFormat="$Log__DefalutLogTimeFormat"

    # create and replace
    local timeStr=$(Date::Format "$timestamp" "${logTimeFormat}")
    pattern="${pattern/$timeConfig/$timeStr}"

    # get next timeConfig
    timeConfig=$(Regex::Matcher "$pattern" '.*(\$\{time\}).*' 1)
  done

  echo "$pattern"
}
export -f Log::PopulateTime

Log::isAvailableLevelStr(){
  # Usage: Log::isAvailableLevelStr 'levelStr'
  if [[ $1 =~ ^(DEBUG|INFO|WARN|ERROR|FATAL)$ ]]; then
    return 0
  else
    return 1
  fi
}
export -f Log::isAvailableLevelStr