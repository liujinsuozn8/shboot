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
# default value of log
declare -g Log__DefalutLevel=DEBUG
declare -g Log__DefalutLogTimeFormat='%Y/%m/%d %H:%M:%S'
declare -g Log__DefalutLogPattern='${time} [${level}] Method:[${shell}--${method}] Message:${msg}'

declare -g Log__Type_Console='Console'
declare -g Log__Type_FileAppender='FileAppender'
declare -g Log__Type_DailyRollingFileAppender='DailyRollingFileAppender'
################################################################
# registry appender
declare -ig Log_Root_Level=DEBUG
declare -ag Log_Global_Appender

LogAppenderRegistry_FileAppender(){
  # Usage LogAppenderRegistry_FileAppender appenderName innerAppenderName settings
#appender.D.Target = E://logs/log.log
#appender.D.Append = true
#appender.D.Threshold = DEBUG
#appender.D.logPattern = ''
#appender.D.timeFormat = ''


  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern
  local logTimeFormat

  while [ $# -gt 0 ]; do
    case "$1" in
      -target=*)
      #  temp="${1#*=}"
      #  [ -z "$temp" ] && throw 'Target is empty'
      #
      ;;
      -threshold=*)
        local temp="${1#*=}"
        [ -z "$temp" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        threshold=${!temp}
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $temp"
      ;;
      -logPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;
      -logTimeFormat=*)
        logTimeFormat="${1#*=}"
        [ -z "$logTimeFormat" ] && throw "LogAppender [${appenderName}]: LogTimeFormat is empty"
      ;;
      *)
        throw "LogAppender ${appenderName}: Illegal parameter: $1"
      ;;
    esac
    shift
  done

  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}['threshold']=\$Log__DefalutLevel
  else
    eval ${innerAppenderName}['threshold']=\$threshold
  fi

  if [ -z "$logPattern" ]; then
    eval ${innerAppenderName}['logPattern']="\$Log__DefalutLogPattern"
  else
    eval ${innerAppenderName}['logPattern']="\$logPattern"
  fi

  if [ -z "$logTimeFormat" ]; then
    eval ${innerAppenderName}['logTimeFormat']="\$Log__DefalutTimeFormat"
  else
    eval ${innerAppenderName}['logTimeFormat']="\$logTimeFormat"
  fi
}

LogAppenderRegistry_Console(){
  # Usage LogAppenderRegistry_Console appenderName innerAppenderName settings

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern
  local timeFormat

  while [ $# -gt 0 ]; do
    case "$1" in
      -target=*)
      #  temp="${1#*=}"
      #  [ -z "$temp" ] && throw 'Target is empty'
      ;;
      -threshold=*)
        local temp="${1#*=}"
        [ -z "$temp" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        threshold=${!temp}
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $temp"
      ;;
      -logPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;
      -logTimeFormat=*)
        logTimeFormat="${1#*=}"
        [ -z "$logTimeFormat" ] && throw "LogAppender [${appenderName}]: LogTimeFormat is empty"
      ;;
      *)
        throw "LogAppender ${appenderName}: Illegal parameter: $1"
      ;;
    esac
    shift
  done

  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}['threshold']=\$Log__DefalutLevel
  else
    eval ${innerAppenderName}['threshold']=\$threshold
  fi

  if [ -z "$logPattern" ]; then
    eval ${innerAppenderName}['logPattern']="\$Log__DefalutLogPattern"
  else
    eval ${innerAppenderName}['logPattern']="\$logPattern"
  fi

  if [ -z "$logTimeFormat" ]; then
    eval ${innerAppenderName}['logTimeFormat']="\$Log__DefalutLogTimeFormat"
  else
    eval ${innerAppenderName}['logTimeFormat']="\$logTimeFormat"
  fi
}

LogAppenderRegistry(){
  # Usage: LogAppenderRegistry appenderName type [key=value]
  local appenderName="$1"
  local type="$2"
  shift 2

  # 1. create inner name
  innerAppenderName="__log_appender_${appenderName}"

  # 2. check appender exist
  [ -n "${Log_Global_Appender[$innerAppenderName]}" ] && throw "Log Appender[$appenderName] has been registered" 

  # 3. registry to cache
  Log_Global_Appender+=("${innerAppenderName}")

  # 4. create appender
  eval declare -Ag $innerAppenderName
  eval ${innerAppenderName}['type']=\${type}

  # 5. init
  eval LogAppenderRegistry_${type} "\${appenderName}" "\${innerAppenderName}" "\$@"
}