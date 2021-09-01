################################################################
# log level
declare -Ag Log__LevelStr

declare -ig DEBUG=10
declare -ig INFO=20
declare -ig WARN=30
declare -ig ERROR=40
declare -ig FATAL=50

Log__LevelStr[DEBUG]="DEBUG"
Log__LevelStr[INFO]="INFO "
Log__LevelStr[WARN]="WARN "
Log__LevelStr[ERROR]="ERROR"
Log__LevelStr[FATAL]="FATAL"

################################################################
declare -ig Log_Root_Level=DEBUG

# default value of log
declare -g Log__DefalutLevel=DEBUG
#declare -g Log__DefalutLogTimeFormat='%Y/%m/%d %H:%M:%S'
declare -g Log__DefalutLogTimeFormat='yyyyMMdd-HHmmss'
declare -g Log__DefalutLogPattern='${time} [${level}] Method:[${shell}--${method}] Message:${msg}'

declare -g Log__Type_Console='Console'
declare -g Log__Type_FileAppender='FileAppender'
declare -g Log__Type_DailyRollingFileAppender='DailyRollingFileAppender'

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

  echo "$pattern"
}