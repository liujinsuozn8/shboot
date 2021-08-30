
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

# import log/base
# LogAppenderRegistry 'ma' 'Console' -logPattern='${time} [${level}] Method:[${shell}--${method}] Message:${msg}' -threshold='DEBUG'
# Log::DEBUG 'testmsg2'
# Log::INFO 'testmsg3'

import string/regex
a='${time}{%Y/%m/%d %H:%M:%S} [${level}]'
Regex::Matcher "$a" '(\$\{time\}[^\}]*\}).*' 1
b=$(Regex::Matcher "$a" 'ssss')
if [ -z "$b" ];then
  echo 'empty'
fi
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
