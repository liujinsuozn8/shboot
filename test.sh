
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/base
#LogAppenderRegistry 'ma' 'Console' -logPattern='${time}{%Y/%m/%d} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='INFO'

LogAppenderRegistry 'ma' 'Console' -logPattern='${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='INFO'
LogAppenderRegistry 'xx' 'Console' -logPattern='${time}{yyyy/MM/dd HH:mm:ss.SSSS} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='INFO'
Log::DEBUG 'testmsg2'
Log::INFO 'testmsg3'

# timestamp='1630422072-343623000'
# seconds=${timestamp%-*}
# nano=${timestamp#*-}
# echo "$nano"
# 1630422072-343623000
# 1630424710 371353700
# 0123456789 012345678
# timestamp='1630422072343623000'
# seconds=${timestamp:0:10}
# nano=${timestamp:10}
# echo "$seconds"
# echo "$nano"

import date/base
# import string/regex

a=$(Date::FormatNow 'yyyy/MM/dd HH:mm:ss.SSSS E')

echo $a

############################################################
#appender.stdout = Console
#appender.stdout.Target = STDERR
#appender.stdout.Threshold = DEBUG
#appender.stdout.LogPattern = ${time}{%Y/%m/%d %H:%M:%S} [${level}] Method:[${shell}--${method}] msg:${msg}
#appender.stdout.LogTimeFormat = %Y/%m/%d %H:%M:%S


#appender.D = FileAppender
#appender.D.Target = E://logs/log.log
#appender.D.Append = true
#appender.D.Threshold = DEBUG
#appender.D.logPattern = ''
#appender.D.timeFormat = ''


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
