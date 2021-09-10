
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import log/base
import log/common

# load appender
if [ -f "$Log__PropertiesPath" ]; then
  import log/load/autoload
  Log::LoadPropertiesAppender "$Log__PropertiesPath"
else
  import log/load/default
  Log::LoadDefaultAppender
fi