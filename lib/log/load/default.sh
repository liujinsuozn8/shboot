import log/base
import log/registry
import log/appender

LogAppenderRegistry 'DefalutAppender' 'Console' \
  '-LogPattern=${time}{yyyy/MM/dd HH:mm:ss.SSS}--${time}{} [${level}] Method:[${shell}--${method}] Message:${msg}' \
  -Threshold='DEBUG'

  # "-LogPattern=${Log__DefalutLogPattern}" \