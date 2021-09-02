
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/base

LogAppenderRegistry 'ma' 'Console' -logPattern='${time}{yyyy/MM/dd HH:mm:ss.SSS}--${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='INFO'
# LogAppenderRegistry 'xx' 'FileAppender' -logPattern='${time}{yyyy/MM/dd HH:mm:ss.SSSS} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='INFO' -file='/logstest' -append='true'
LogAppenderRegistry 'xx' 'RandomAccessFile' -logPattern='${time}{yyyy/MM/dd HH:mm:ss.SSSS} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='INFO' -file='/logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log' -append='true'
Log::DEBUG 'testmsg2'
Log::INFO 'testmsg3'
Log::INFO 'testmsg4'
Log::INFO 'testmsg5'

# declare -Ag xx
# xx['file']='/logstest/log-${time}{yyyy-MM-dd}.log/'
# prepareLogFilePath "xx"
# prepareLogFilePath "xx"
# prepareLogFilePath "xx"

# import file/base
# filePath='/logstest/log-${time}{yyyy-MM-dd}.log'
# File::isFilePathStr "$filePath"




############################################################
#appender.stdout = Console
#appender.stdout.Target = STDERR
#appender.stdout.Threshold = DEBUG
#appender.stdout.LogPattern = ${time}{%Y/%m/%d %H:%M:%S} [${level}] Method:[${shell}--${method}] msg:${msg}
#appender.stdout.LogTimeFormat = %Y/%m/%d %H:%M:%S


#appender.D = FileAppender
#appender.D.File = /logstest/log-${time}{yyyy-MM-dd}.log
#appender.D.Append = true
#appender.D.Threshold = DEBUG
#appender.D.logPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}'



#abc(){
#  echo ${FUNCNAME[@]}
#}

#cde(){
#  abc
#  echo ${BASH_SOURCE[@]} ${FUNCNAME[-1]}
#}




# CreateConsoleLogAppender "ma" "mypattern"
# # CreateConsoleLogAppender 'ma'
# LoggerRegistry 'ma' __console__Logger_ma

# ${__log_appender['ma']} 'test'



# Log::DEBUG 'xxxxxx'
# -->
# for rootLogger
#

####################################################
# ----- task -----
# bash version compare 
