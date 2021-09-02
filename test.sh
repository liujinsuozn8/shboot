
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


#appender.RAF = RandomAccessFile
#appender.RAF.File = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
#appender.RAF.Append = true
#appender.RAF.Threshold = DEBUG
#appender.RAF.logPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}'

#appender.RF = RollingFile
#appender.RF.File = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
#appender.RF.Append = true
#appender.RF.Threshold = DEBUG
#appender.RF.logPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}'



####################################################
# ----- task -----
# bash version compare 
