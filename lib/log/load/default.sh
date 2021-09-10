
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import log/common
import log/registry

Log::LoadDefaultAppender(){
  # Usage: Log::LoadDefaultAppender
  Log::AppenderRegistry 'DefalutAppender' 'Console' \
    "-LogPattern=${Log__DefalutLogPattern}" \
    -Threshold='DEBUG'
}
export -f Log::LoadDefaultAppender