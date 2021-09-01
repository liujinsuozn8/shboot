
############################################
# Console
############################################

LogOutput_Console(){
  # Usage: __output_log_Console appenderName msg
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
  eval ${innerAppenderName}['logPattern']="\$logPattern"

  # 2. save threshold
  if [ -z "$threshold" ]; then
    eval ${innerAppenderName}['threshold']=\$Log__DefalutLevel
  else
    eval ${innerAppenderName}['threshold']=\$threshold
  fi
}

############################################
# FileAppender
############################################

LogOutput_FileAppender(){
  # Usage: __output_log_FileAppender appenderName msg
  # 1. 
  :
}

LogAppenderRegistry_FileAppender(){
  # Usage LogAppenderRegistry_FileAppender appenderName innerAppenderName settings
  # settings: -threshold, -logPattern, -flie, -append

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local filePath
  local append
  local logPattern

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
      -flie=*)
        filePath="${1#*=}"
        [ -z "$filePath" ] && throw "LogAppender [${appenderName}]: FilePath is empty"
      ;;
      *)
        throw "LogAppender ${appenderName}: Illegal parameter: $1"
      ;;
    esac
    shift
  done

  # 1. check and save flie
  # 1.1 empty check
  [ -z "$filePath" ] && throw "LogAppender [${appenderName}]: FilePath is empty"

  # 1.2 check parameter is a avaliable path of file
  if File::isFilePathStr "$filePath" ; then
    throw "LogAppender ${appenderName}: Illegal file: $1. Please do not end with '..' or '/'"
  fi

  # 1.3 populate time
  local timestamp=$(Date::NowTimestamp)
  local curFilePath=$(Log::PopulateTime "$timestamp" "$filePath")
  eval curFilePath="$curFilePath"
  
  # 1.4 check file is writable
  if [ -z "$curFilePath" ]; then
    # try to create file
    File::TryTouch "$curFilePath"
    if [ $? -ne 0]; then
      throw "LogAppender ${appenderName}: Illegal file: ${curFilePath}. Can not create."
    fi
  else
    # check writable
    if [ ! -w "$curFilePath" ]; then
      throw "LogAppender ${appenderName}: Illegal file: ${curFilePath}. Can not write."
    fi
  fi
  
  eval ${innerAppenderName}['file']="\$filePath"

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
    File::clearFile "$curFilePath"
  fi
}