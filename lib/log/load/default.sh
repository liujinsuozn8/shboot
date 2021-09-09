
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
#---------------------------------------

import log/base
import log/registry
import log/appender

Log::AppenderRegistry 'DefalutAppender' 'Console' \
  "-LogPattern=${Log__DefalutLogPattern}" \
  -Threshold='DEBUG'

  # '-LogPattern=${time}{yyyy/MM/dd HH:mm:ss.SSS}--${time}{} [${level}] Method:[${shell}--${method}] Message:${msg}' \
  # "-LogPattern=" \