
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/base
import file/base
import date/base
import console/base
import console/color

#########################################################
# common
#########################################################
populateLogFilePath(){
  # Usage: populateLogFilePath 'filePath' 'timestamp'
  local filePath="$1"
  local timestamp="$2"

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
export -f populateLogFilePath

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
export -f initLogFile

Log::DoRollingLogFile(){
  # Usage: Log::RollingLogFile 'filePattern' 'originPath'
  local filePattern="$1"
  local originPath="$2"
  local rollFileRegex="${filePattern//%i/[0-9]+}"

  # 1. get count of rolled log
  local logCount=$(File::GrepCountFromFilePath "$rollFileRegex")
  ((logCount=logCount+1))

  # 2. roll
  mv "$originPath" "${filePattern//%i/${logCount}}"
}

############################################
# Appender: Console
############################################

Log::Output_Console(){
  # Usage: Log::Output_Console loglevel appenderName timestamp msg
  case $1 in
    DEBUG)
      echo -e "$4"
    ;;
    INFO)
      Console::EchoGreen "$4"
    ;;
    WARN)
      Console::EchoYellow "$4"
    ;;
    ERROR)
      Console::EchoRed "$4"
    ;;
    FATAL)
      Console::EchoWithColor $Color_BG_Red $Color_Text_White "$4"
    ;;
  esac
}
export -f Log::Output_Console

Log::RemoveAppender_Console(){
  # Usage: Log::RemoveAppender_Console 'appenderName'
  unset "${1}_type"
  unset "${1}_logPattern"
  unset "${1}_threshold"
}
export -f Log::RemoveAppender_Console

Log::AppenderRegistry_Console(){
  # Usage Log::AppenderRegistry_Console appenderName innerAppenderName settings
  # settings: -Target, -Threshold, -LogPattern

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern

  while [ $# -gt 0 ]; do
    case "$1" in
      -Target=*)
      #  temp="${1#*=}"
      #  [ -z "$temp" ] && throw 'Target is empty'
      ;;
      -Threshold=*)
        threshold="${1#*=}"
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        if Log::isAvailableLevelStr "$threshold"; then
          threshold=${!threshold}
        else
          throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $threshold"
        fi
      ;;
      -LogPattern=*)
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
  eval export ${innerAppenderName}'_logPattern'="\$logPattern"

  # 2. save threshold
  if [ -z "$threshold" ]; then
    eval export ${innerAppenderName}'_threshold'=\$Log_Root_Level
  else
    eval export ${innerAppenderName}'_threshold'=\$threshold
  fi
}
export -f Log::AppenderRegistry_Console

############################################
# Appender: RandomAccessFile
############################################

Log::Output_RandomAccessFile(){
  # Usage: Log::Output_RandomAccessFile loglevel appenderName timestamp msg
  local timestamp="$3"

  eval local filePath=\${$2'_fileName'}

  local realFilePath=$(populateLogFilePath "$filePath" "$timestamp")

  initLogFile "$2" "$realFilePath"

  echo "$4" >> "$realFilePath"
}
export -f Log::Output_RandomAccessFile

Log::RemoveAppender_RandomAccessFile(){
  # Usage: Log::RemoveAppender_RandomAccessFile 'appenderName'
  unset "${1}_type"
  unset "${1}_fileName"
  unset "${1}_logPattern"
  unset "${1}_threshold"
  unset "${1}_append"
}
export -f Log::RemoveAppender_RandomAccessFile

Log::AppenderRegistry_RandomAccessFile(){
  # Usage Log::AppenderRegistry_RandomAccessFile appenderName innerAppenderName settings
  # settings: -Threshold, -LogPattern, -FileName, -Append

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern
  local filePath
  local append

  while [ $# -gt 0 ]; do
    case "$1" in
      -Threshold=*)
        threshold="${1#*=}"
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        if Log::isAvailableLevelStr "$threshold"; then
          threshold=${!threshold}
        else
          throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $threshold"
        fi
      ;;
      -LogPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;
      -Append=*)
        append="${1#*=}"
        [ -z "$append" ] && throw "LogAppender [${appenderName}]: Append is empty"

        if [ "$append" != 'true' ] && [ "$append" != 'false' ]; then
          throw "LogAppender [${appenderName}]: Illegal $append. Append must be one of [true, false]. Now is $append"
        fi
      ;;
      -FileName=*)
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
  # 1.1 check parameter is a avaliable path of file
  if ! File::IsFilePathStr "$fileName" ; then
    throw "LogAppender ${appenderName}: Illegal fileName: ${fileName}  Please do not end with '..' or '/'"
  fi

  # 1.2 populate time
  eval export ${innerAppenderName}'_fileName'="\$fileName"
  local timestamp=$(Date::NowTimestamp)
  local realFilePath=$(populateLogFilePath "$fileName" "$timestamp")

  # 2. save logPattern
  [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
  eval export ${innerAppenderName}'_logPattern'="\$logPattern"

  # 3. init log file
  initLogFile "$innerAppenderName" "$realFilePath"

  # 4. save threshold
  if [ -z "$threshold" ]; then
    eval export ${innerAppenderName}'_threshold'=\$Log_Root_Level
  else
    eval export ${innerAppenderName}'_threshold'=\$threshold
  fi

  # 5. save append
  if [ -z "$append" ]; then
    eval export ${innerAppenderName}'_append'='true'
  else
    eval export ${innerAppenderName}'_append'="\$append"
  fi
  # if append is 'false', clear file
  if [ "$append" == 'false' ]; then
    File::ClearFile "$realFilePath"
  fi
}
export -f Log::AppenderRegistry_RandomAccessFile

############################################
# Appender: RollingFile
############################################

Log::Output_RollingFile(){
  # Usage: Log::Output_RollingFile loglevel appenderName timestamp msg
  local appenderName="$2"
  local timestamp="$3"
  local msg="$4"

  # 1. populate filepath
  eval local filePath=\${${appenderName}'_fileName'}
  local realFilePath=$(populateLogFilePath "$filePath" "$timestamp")

  # 2. populate filePattern
  eval local filePattern=\${${appenderName}'_filePattern'}
  local realFilePatternPath=$(populateLogFilePath "$filePattern" "$timestamp")

  # 3. check roll policy
  local rolled='false'
  local nowSecond=${timestamp:0:10}
  local lastRollingSecond
  
  # 3.1 dailyTriggeringPolicy
  eval local dailyTriggeringPolicy=\${${appenderName}'_dailyTriggeringPolicy'}
  if [ "$dailyTriggeringPolicy" == 'true' ]; then
    local zeroAMSecond=$(Date::TodayZeroAMSecond)
    eval local todayZeroAMSecond=\${${appenderName}'_todayZeroAMSecond'}

    if [ "$zeroAMSecond" != "$todayZeroAMSecond" ]; then
      Log::DoRollingLogFile "$realFilePatternPath" "$realFilePath"
      rolled='true'
      lastRollingSecond="$nowSecond"

      eval export \${${appenderName}'_todayZeroAMSecond'}=\${zeroAMSecond}
    fi
  fi

  # 3.2 timeBasedTriggeringPolicy
  if [ "$rolled" == 'false' ]; then
    eval local timeBasedTriggeringPolicy=\${${appenderName}'_timeBasedTriggeringPolicy'}
    eval lastRollingSecond=\${${appenderName}'_lastRollingSecond'}
  
    if [ ! -z "$timeBasedTriggeringPolicy" ] && [ $[nowSecond - lastRollingSecond] -ge $timeBasedTriggeringPolicy ];then
      Log::DoRollingLogFile "$realFilePatternPath" "$realFilePath"
      rolled='true'
      lastRollingSecond="$nowSecond"
    fi
  fi

  # 3.3 sizeBasedTriggeringPolicy
  if [ "$rolled" == 'false' ]; then
    eval local sizeBasedTriggeringPolicy=\${${appenderName}'_sizeBasedTriggeringPolicy'}

    if [ ! -z "$sizeBasedTriggeringPolicy" ]; then
      local realFilePathSize="$(File::FileSize "$realFilePath")"
      
      if [ $realFilePathSize -ge $sizeBasedTriggeringPolicy ]; then
        Log::DoRollingLogFile "$realFilePatternPath" "$realFilePath"
        rolled='true'
        lastRollingSecond="$nowSecond"
      fi
    fi
  fi

  # 4. save lastRollingSecond
  if [ ! -z "$lastRollingSecond" ]; then
    # !!! has been rolled in 3[Policy]
    eval export ${appenderName}'_lastRollingSecond'="\$lastRollingSecond"
  fi

  # 5. init realFilePath
  initLogFile "$appenderName" "$realFilePath"

  # 6. output log
  echo "$msg" >> "$realFilePath"
}
export -f Log::Output_RollingFile

Log::RemoveAppender_RollingFile(){
  # Usage: Log::RemoveAppender_RollingFile 'appenderName'
  eval unset "${1}_type"
  eval unset "${1}_todayZeroAMSecond"
  eval unset "${1}_fileName"
  eval unset "${1}_filePattern"
  eval unset "${1}_sizeBasedTriggeringPolicy"
  eval unset "${1}_timeBasedTriggeringPolicy"
  eval unset "${1}_dailyTriggeringPolicy"
  eval unset "${1}_onStartupTriggeringPolicy"
  eval unset "${1}_logPattern"
  eval unset "${1}_threshold"
  eval unset "${1}_lastRollingSecond"
}
export -f Log::RemoveAppender_RollingFile

Log::AppenderRegistry_RollingFile(){
  # Usage Log::AppenderRegistry_RollingFile appenderName innerAppenderName settings
  # settings: 
  #      -Threshold, -LogPattern, -FileName, -FilePattern
  #      -PoliciesOnStartupTriggeringPolicy, -PoliciesSizeBasedTriggeringPolicy
  #      -PoliciesOtimeBasedTriggeringPolicy, -PoliciesDailyTriggeringPolicy

  local appenderName="$1"
  local innerAppenderName="$2"
  shift 2

  local threshold
  local logPattern
  local fileName
  local filePattern
  local sizeBasedTriggeringPolicy
  local timeBasedTriggeringPolicy
  local dailyTriggeringPolicy
  local onStartupTriggeringPolicy

  while [ $# -gt 0 ]; do
    case "$1" in
      -Threshold=*)
        threshold="${1#*=}"
        [ -z "$threshold" ] && throw "LogAppender [${appenderName}]: Threshold is empty"

        # levelStr ---> levelCode
        if Log::isAvailableLevelStr "$threshold"; then
          threshold=${!threshold}
        else
          throw "LogAppender [${appenderName}]: Illegal threshold. Threshold must be one of [DEBUG, INFO, WARN, ERROR, FATAL]. Now is $threshold"
        fi
      ;;

      -LogPattern=*)
        logPattern="${1#*=}"
        [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"
      ;;

      -FileName=*)
        fileName="${1#*=}"
        [ -z "$fileName" ] && throw "LogAppender [${appenderName}]: FileName is empty"
      ;;

      -FilePattern=*)
        filePattern="${1#*=}"
        [ -z "$filePattern" ] && throw "LogAppender [${appenderName}]: FilePattern is empty"
      ;;

      -PoliciesSizeBasedTriggeringPolicy=*)
        sizeBasedTriggeringPolicy="${1#*=}"
        [ -z "$sizeBasedTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: SizeBasedTriggeringPolicy is empty"
      ;;

      -PoliciesTimeBasedTriggeringPolicy=*)
        timeBasedTriggeringPolicy="${1#*=}"
        [ -z "$timeBasedTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: TimeBasedTriggeringPolicy is empty"
      ;;

      -PoliciesDailyTriggeringPolicy=*)
        dailyTriggeringPolicy="${1#*=}"
        [ -z "$dailyTriggeringPolicy" ] && throw "LogAppender [${appenderName}]: DailyTriggeringPolicy is empty"

        if [ "$dailyTriggeringPolicy" != 'true' ] && [ "$dailyTriggeringPolicy" != 'false' ]; then
          throw "LogAppender [${appenderName}]: Illegal $dailyTriggeringPolicy. DailyTriggeringPolicy must be one of [true, false]. Now is $dailyTriggeringPolicy"
        fi
      ;;

      -PoliciesOnStartupTriggeringPolicy=*)
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

  # 1. check
  # 1.1 Policy
  # 1.1.1 check policy
  # One of these three properties must be set, otherwise it cannot be started.
  # Moreover, if `dailytriggingpolicy` is set, it can only be the string `true`
  if [ -z "$sizeBasedTriggeringPolicy" ] && [ -z "$timeBasedTriggeringPolicy" ] && [ "$dailyTriggeringPolicy" != 'true' ]; then
    throw "LogAppender ${appenderName}: No policy set. Pleace set 'SizeBasedTriggeringPolicy' or 'SimeBasedTriggeringPolicy' or 'DailyTriggeringPolicy = true'"
  fi 

  # 1.1.2 Set defalut value for Policy
  # !!! sizeBasedTriggeringPolicy: default value is ''
  # !!! timeBasedTriggeringPolicy: default value is ''

  if [ -z "$dailyTriggeringPolicy" ]; then
    dailyTriggeringPolicy='false'
  fi 
  
  if [ -z "$onStartupTriggeringPolicy" ]; then
    onStartupTriggeringPolicy='false'
  fi

  #   unit str ----> second
  if [ ! -z "$timeBasedTriggeringPolicy" ]; then
    timeBasedTriggeringPolicy=$(Date::TimeUnitStrToSecond "$timeBasedTriggeringPolicy")

    [ $timeBasedTriggeringPolicy -eq 0 ] && throw "LogAppender ${appenderName}: Illegal TimeBasedTriggeringPolicy. TimeBasedTriggeringPolicy is 0 or cannot be resolved"
  fi

  #   unit str ----> size
  if [ ! -z "$sizeBasedTriggeringPolicy" ]; then
    sizeBasedTriggeringPolicy=$(File::SizeUnitStrToSize "$sizeBasedTriggeringPolicy")

    [ $sizeBasedTriggeringPolicy -eq 0 ] && throw "LogAppender ${appenderName}: Illegal SizeBasedTriggeringPolicy. SizeBasedTriggeringPolicy is 0 or cannot be resolved"
  fi

  # 1.2. File
  # 1.2.1 check fileName is a avaliable path of file
  if ! File::IsFilePathStr "$fileName" ; then
    throw "LogAppender ${appenderName}: Illegal fileName: ${fileName}  Please do not end with '..' or '/'"
  fi

  # 1.2.2 check fileName is a avaliable path of file
  if ! File::IsFilePathStr "$filePattern" ; then
    throw "LogAppender ${appenderName}: Illegal file: ${filePattern}  Please do not end with '..' or '/'"
  fi

  # 1.3 check logPattern
  [ -z "$logPattern" ] && throw "LogAppender [${appenderName}]: LogPattern is empty"

  # 1.4 filePattern
  # 1.4.1 exist
  [ -z "$filePattern" ] && throw "LogAppender [${appenderName}]: FilePattern is empty"

  # 1.4.2 ${i} --> %i
  local filePtnDir=$(File::Dirname "$filePattern")
  # 1.4.3 check: ${i}' can only be used in file names
  if String::Contains "$filePtnDir" '${i}'; then
    throw "LogAppender [${appenderName}]: In filepattern, \`%n\` can only be used in file name, not directories. filePattern=${filePattern}"
  fi

  local realFilePattern="${filePattern//\$\{i\}/%i}"
  
  #========================================================

  # 2. create Second
  local timestamp=$(Date::NowTimestamp)
  local nowSecond=${timestamp:0:10}
  local todayZeroAMSecond=$(Date::ZeroAMSecond "$timestamp")

  #========================================================
  # 3. save
  # save zero second
  eval export ${innerAppenderName}'_todayZeroAMSecond'="\$todayZeroAMSecond"

  # save fileName
  eval export ${innerAppenderName}'_fileName'="\$fileName"
  # save filePattern
  eval export ${innerAppenderName}'_filePattern'="\$realFilePattern"

  # save Policy
  eval export ${innerAppenderName}'_sizeBasedTriggeringPolicy'="\$sizeBasedTriggeringPolicy"
  eval export ${innerAppenderName}'_timeBasedTriggeringPolicy'="\$timeBasedTriggeringPolicy"
  eval export ${innerAppenderName}'_dailyTriggeringPolicy'="\$dailyTriggeringPolicy"
  eval export ${innerAppenderName}'_onStartupTriggeringPolicy'="\$onStartupTriggeringPolicy"

  # save logPattern
  eval export ${innerAppenderName}'_logPattern'="\$logPattern"

  # save threshold
  if [ -z "$threshold" ]; then
    eval export ${innerAppenderName}'_threshold'=\$Log_Root_Level
  else
    eval export ${innerAppenderName}'_threshold'=\$threshold
  fi

  #========================================================

  # 4. check
  # 4.1 filePattern
  #     populate realFilePattern
  local realFilePatternPath=$(populateLogFilePath "$realFilePattern" "$timestamp")
  #     get directory from `realFilePatternPath`
  local realFilePatternDir=$(File::Dirname "$realFilePatternPath")

  #     try mkdir. stop when error
  mkdir -p "$realFilePatternDir"
  [ $? -ne 0 ] && throw "LogAppender [${appenderName}]: FilePattern Error. Can not exec command: \`mkdir\` $realFilePatternDir"

  #     check: Can create a file in realFilePatternDir
  ! File::CanCreateFileInDir "$realFilePatternDir" && throw "LogAppender [${appenderName}]: FilePattern Error. Permission denied"

  # 4.2 Populate FileName
  local realFilePath=$(populateLogFilePath "$fileName" "$timestamp")

  # 4.3 Policy (if log exists)
  local realFilePathExist
  local realFilePathMTime
  if [ -f "$realFilePath" ]; then
    realFilePathExist='true'
    realFilePathMTime="$(File::MTime "$realFilePath")"
  else
    realFilePathExist='false'
  fi

  local lastRollingSecond
  if [ "$onStartupTriggeringPolicy" == 'true' ] && [ -f "$realFilePath" ]; then
    local rolled='false'

    # 4.3.1 dailyTriggeringPolicy
    if [ "$dailyTriggeringPolicy" == 'true' ] && [ $realFilePathMTime -le $todayZeroAMSecond ]; then
      Log::DoRollingLogFile "$realFilePatternPath" "$realFilePath"
      rolled='true'
      lastRollingSecond="$nowSecond"
    fi

    # 4.3.2 timeBasedTriggeringPolicy
    if [ "$rolled" == 'false' ] && [ ! -z "$timeBasedTriggeringPolicy" ] && [ $[nowSecond - realFilePathMTime] -ge $timeBasedTriggeringPolicy ];then
      Log::DoRollingLogFile "$realFilePatternPath" "$realFilePath"
      rolled='true'
      lastRollingSecond="$nowSecond"
    fi

    # 4.3.3 sizeBasedTriggeringPolicy
    if [ "$rolled" == 'false' ] && [ ! -z "$sizeBasedTriggeringPolicy" ]; then
      local realFilePathSize="$(File::FileSize "$realFilePath")"
      
      if [ $realFilePathSize -ge $sizeBasedTriggeringPolicy ]; then
        Log::DoRollingLogFile "$realFilePatternPath" "$realFilePath"
        rolled='true'
        lastRollingSecond="$nowSecond"
      fi
    fi
  fi


  # 5. save lastRollingSecond
  if [ ! -z "$lastRollingSecond" ]; then
    # !!! has been rolled in 4.3[onStartupTriggeringPolicy]
    eval export ${innerAppenderName}'_lastRollingSecond'="\$lastRollingSecond"
  elif [ "$realFilePathExist" == 'true' ]; then
    eval export ${innerAppenderName}'_lastRollingSecond'="\$realFilePathMTime"
  else
    eval export ${innerAppenderName}'_lastRollingSecond'="\$nowSecond"
  fi

  # 6 init realFilePath
  initLogFile "$innerAppenderName" "$realFilePath"
}

export -f Log::AppenderRegistry_RollingFile