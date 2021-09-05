
############################################
# Console
############################################

LogOutput_Console(){
  # Usage: LogOutput_Console appenderName msg
  echo "$2" 
}

LogAppenderRegistry_Console(){
  # Usage LogAppenderRegistry_Console appenderName innerAppenderName settings
  # settings: -target, -threshold, -logPattern

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern

  while [ $# -gt 0 ]; do
    case "$1" in
      -target=*)
      #  temp="${1#*=}"
      #  [ -z "$temp" ] && throw 'Target is empty'
      ;;
      -threshold=*)
        threshold="${1#*=}"
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        if __isAvailableLevelStr "$threshold"; then
          threshold=${!threshold}
        else
          throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $threshold"
        fi
      ;;
      -logPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;
      *)
        throw "LogAppender ${appenderName}: Illegal parameter: $1"
      ;;
    esac
    shift
  done

  # 1. save logPattern
  [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
  eval ${innerAppenderName}'_logPattern'="\$logPattern"

  # 2. save threshold
  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}'_threshold'=\$Log__DefalutLevel
  else
    eval ${innerAppenderName}'_threshold'=\$threshold
  fi
}

############################################
# RandomAccessFile
############################################

LogOutput_RandomAccessFile(){
  # Usage: LogOutput_RandomAccessFile appenderName msg
  local timestamp=$(Date::NowTimestamp)
  local realFilePath=$(prepareLogFilePath "$1" "$timestamp")
  initLogFile "$1" "$realFilePath"

  echo "$2" >> "$realFilePath"
}

LogAppenderRegistry_RandomAccessFile(){
  # Usage LogAppenderRegistry_RandomAccessFile appenderName innerAppenderName settings
  # settings: -threshold, -logPattern, -fileName, -append

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern
  local filePath
  local append

  while [ $# -gt 0 ]; do
    case "$1" in
      -threshold=*)
        threshold="${1#*=}"
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        if __isAvailableLevelStr "$threshold"; then
          threshold=${!threshold}
        else
          throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $threshold"
        fi
      ;;
      -logPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;
      -append=*)
        append="${1#*=}"
        [ -z "$append" ] && throw "LogAppender [${appenderName}]: Append is empty"

        if [ "$append" != 'true' ] && [ "$append" != 'false' ]; then
          throw "LogAppender [${appenderName}]: Illegal $append. Append must be one of [true, false]. Now is $append"
        fi
      ;;
      -fileName=*)
        fileName="${1#*=}"
        [ -z "$fileName" ] && throw "LogAppender [${appenderName}]: FileName is empty"
      ;;
      *)
        throw "LogAppender ${appenderName}: Illegal parameter: $1"
      ;;
    esac
    shift
  done

  # 1. check and init file
  # 1.1 empty check
  [ -z "$fileName" ] && throw "LogAppender [${appenderName}]: FileName is empty"

  # 1.2 check parameter is a avaliable path of file
  if ! File::IsFilePathStr "$fileName" ; then
    throw "LogAppender ${appenderName}: Illegal file: $1. Please do not end with '..' or '/'"
  fi

  # 1.3 populate time
  eval ${innerAppenderName}'_fileName'="\$fileName"
  local timestamp=$(Date::NowTimestamp)
  local realFilePath=$(prepareLogFilePath "$innerAppenderName" "$timestamp")

  # 1.4 init file
  initLogFile "$innerAppenderName" "$realFilePath"

  # 2. save logPattern
  [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
  eval ${innerAppenderName}'_logPattern'="\$logPattern"

  # 3. save threshold
  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}'_threshold'=\$Log__DefalutLevel
  else
    eval ${innerAppenderName}'_threshold'=\$threshold
  fi

  # 4. save append
  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}'_append'='true'
  else
    eval ${innerAppenderName}'_append'="\$append"
  fi
  # if append is 'false', clear file
  if [ "$append" == 'false' ]; then
    File::ClearFile "$realFilePath"
  fi
}

prepareLogFilePath(){
  # Usage: prepareLogFilePath 'appenderName' 'timestamp'
  local appenderName="$1"
  local timestamp="$2"
  eval local filePath=\${${appenderName}'_fileName'}

  # 1. populate time
  local realFilePath=$(Log::PopulateTime "$timestamp" "$filePath")

  # 2. extend parameter 
  if String::Contains "$realFilePath" '${yyyy}'; then
    local yyyy=$(Date::Format "$timestamp" "yyyy")
  fi

  if String::Contains "$realFilePath" '${yy}'; then
    local yy=$(Date::Format "$timestamp" "yy")
  fi

  if String::Contains "$realFilePath" '${MM}'; then
    local MM=$(Date::Format "$timestamp" "MM")
  fi

  if String::Contains "$realFilePath" '${dd}'; then
    local dd=$(Date::Format "$timestamp" "dd")
  fi

  eval echo "$realFilePath"
}

initLogFile(){
  # Usage: initLogFile 'appenderName' 'filePath'
  # check file is writable
  if [ -e "$2" ]; then
    # check this path is a file
    if [ ! -f "$2" ]; then
      throw "LogAppender ${1}: Illegal file: ${2}. Can not write."
    fi
    # check writable
    if [ ! -w "$2" ]; then
      throw "LogAppender ${1}: Illegal file: ${2}. Can not write."
    fi
  else
    # try to create file
    File::TryTouch "$2"
    if [ $? -ne 0 ]; then
      throw "LogAppender ${1}: Illegal file: ${2}. Can not create."
    fi
  fi
}

############################################
# RollingFile
############################################
LogAppenderRegistry_RollingFile(){
  # Usage LogAppenderRegistry_RollingFile appenderName innerAppenderName settings
  # settings: 
  #      -threshold, -logPattern, -fileName, -filePattern, -append
  #      -onStartupTriggeringPolicy, -sizeBasedTriggeringPolicy
  #      -timeBasedTriggeringPolicy, -dailyTriggeringPolicy

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern
  local fileName
  local filePattern
  local append
  local sizeBasedTriggeringPolicy
  local timeBasedTriggeringPolicy
  local dailyTriggeringPolicy
  local onStartupTriggeringPolicy

  while [ $# -gt 0 ]; do
    case "$1" in
      -threshold=*)
        threshold="${1#*=}"
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        if __isAvailableLevelStr "$threshold"; then
          threshold=${!threshold}
        else
          throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $threshold"
        fi
      ;;

      -logPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;

      -append=*)
        append="${1#*=}"
        [ -z "$append" ] && throw "LogAppender [${appenderName}]: Append is empty"

        if [ "$append" != 'true' ] && [ "$append" != 'false' ]; then
          throw "LogAppender [${appenderName}]: Illegal $append. Append must be one of [true, false]. Now is $append"
        fi
      ;;

      -fileName=*)
        fileName="${1#*=}"
        [ -z "$fileName" ] && throw "LogAppender [${appenderName}]: FileName is empty"
      ;;

      -filePattern=*)
        filePattern="${1#*=}"
        [ -z "$filePattern" ] && throw "LogAppender [${appenderName}]: FilePattern is empty"
      ;;

      -sizeBasedTriggeringPolicy=*)
        sizeBasedTriggeringPolicy="${1#*=}"
        [ -z "$sizeBasedTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: SizeBasedTriggeringPolicy is empty"
      ;;

      -timeBasedTriggeringPolicy=*)
        timeBasedTriggeringPolicy="${1#*=}"
        [ -z "$timeBasedTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: TimeBasedTriggeringPolicy is empty"
      ;;

      -dailyTriggeringPolicy=*)
        dailyTriggeringPolicy="${1#*=}"
        [ -z "$dailyTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: DailyTriggeringPolicy is empty"

        if [ "$dailyTriggeringPolicy" != 'true' ] && [ "$dailyTriggeringPolicy" != 'false' ]; then
          throw "LogAppender [${appenderName}]: Illegal $dailyTriggeringPolicy. DailyTriggeringPolicy must be one of [true, false]. Now is $dailyTriggeringPolicy"
        fi
      ;;

      -onStartupTriggeringPolicy=*)
        onStartupTriggeringPolicy="${1#*=}"
        [ -z "$onStartupTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: OnStartupTriggeringPolicy is empty"

        if [ "$onStartupTriggeringPolicy" != 'true' ] && [ "$onStartupTriggeringPolicy" != 'false' ]; then
          throw "LogAppender [${appenderName}]: Illegal $onStartupTriggeringPolicy. OnStartupTriggeringPolicy must be one of [true, false]. Now is $onStartupTriggeringPolicy"
        fi
      ;;

      *)
        throw "LogAppender ${appenderName}: Illegal parameter: $1"
      ;;
    esac
    shift
  done

  # 1. save Policy
  if [ -z "$dailyTriggeringPolicy" ]; then
    dailyTriggeringPolicy='false'
  fi

  # check policy
  if [ -z "$sizeBasedTriggeringPolicy" ] && [ -z "$timeBasedTriggeringPolicy" ] && [ -z "$dailyTriggeringPolicy" ]; then
    throw "LogAppender ${appenderName}: No policy set. Pleace set 'SizeBasedTriggeringPolicy' or 'SimeBasedTriggeringPolicy' or 'DailyTriggeringPolicy = true'"
  fi 
  
  if [ -z "$onStartupTriggeringPolicy" ]; then
    onStartupTriggeringPolicy='false'
  fi
  eval ${innerAppenderName}['sizeBasedTriggeringPolicy']="\$sizeBasedTriggeringPolicy"
  eval ${innerAppenderName}['timeBasedTriggeringPolicy']=\$timeBasedTriggeringPolicy
  eval ${innerAppenderName}['dailyTriggeringPolicy']=\$dailyTriggeringPolicy
  eval ${innerAppenderName}['onStartupTriggeringPolicy']=\$onStartupTriggeringPolicy



  # 1. check and init file
  # 1.1 empty check
  [ -z "$fileName" ] && throw "LogAppender [${appenderName}]: FileName is empty"

  # 1.2 check parameter is a avaliable path of file
  if ! File::IsFilePathStr "$fileName" ; then
    throw "LogAppender ${appenderName}: Illegal file: $1. Please do not end with '..' or '/'"
  fi

  # 1.3 populate time
  eval ${innerAppenderName}['file']="\$fileName"
  local realFilePath=$(prepareLogFilePath "$innerAppenderName")

  # 1.4 init file
  initLogFile "$innerAppenderName" "$realFilePath"






  # 2. save logPattern
  [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
  eval ${innerAppenderName}['logPattern']="\$logPattern"

  # 3. save threshold
  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}['threshold']=\$Log__DefalutLevel
  else
    eval ${innerAppenderName}['threshold']=\$threshold
  fi

  # 4. save append
  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}['append']='true'
  else
    eval ${innerAppenderName}['append']="\$append"
  fi
  # if append is 'false', clear file
  if [ "$append" == 'false' ]; then
    File::ClearFile "$realFilePath"
  fi
}
# appender.RF = RollingFile
# appender.RF.FileName = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
# appender.RF.FilePattern = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
# appender.RF.Append = true
# appender.RF.Threshold = DEBUG
# appender.RF.LogPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}
# appender.RF.Policies.OnStartupTriggeringPolicy   = true
# appender.RF.Policies.SizeBasedTriggeringPolicy = 20MB
#    compare size with SizeBasedTriggeringPolicy
#    can check when startup
# appender.RF.Policies.TimeBasedTriggeringPolicy = 10h
#    save start time
#    compare MTime with start time
#    can not check when startup！！！
# appender.RF.Policies.DailyTriggeringPolicy = true
#    when shell start
#       1. get file path
#       2. save timestamp of today zero am in appender
#    Each time the log is printed, get the current 0-point timestamp and compared with the timestamp that saved in the appender
#         If do not same, save the new date and roll log
#    get timestamp of today zero am
#    if now > zero am
# how to get last number of file

